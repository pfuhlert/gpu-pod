# GPU pod on the IMSB cluster

This repository builds a container image with your Python environment and runs it
as a pod with one GPU on the IMSB Kubernetes cluster. You work inside the pod
(shell, VS Code, Jupyter) and keep your code and data on the shared storage.

## What you edit

| File | What goes in it |
|---|---|
| `requirements.txt` | Python packages (pip), one per line |
| `requirements.apt` | System packages (apt), one per line |
| `.env` | Your name, user id, image version and resources (set once) |

Everything else (`Dockerfile`, `statefulset.yaml`, the scripts) you can leave alone.

## Requirements on your machine

- `podman` (to build the image)
- `kubectl` with access to the cluster (ask your supervisor for the kubeconfig)
- `envsubst` (part of `gettext`; already installed on most Linux systems)

## First time

```bash
cp .env.example .env
```

Fill in `.env`. Ask your supervisor for `USER_UID`, `USER_GID`, `REMOTE_REGISTRY` and the storage settings
(`DATA_PVC`, or `DATA_NFS_SERVER` and `DATA_NFS_PATH`, plus `DATA_SUBPATH` for your own folder).
Choose an `APPNAME` that nobody else uses, for example `anna-gpu`.

```bash
./build.sh      # build the image and push it (takes a while the first time)
./start.sh      # start the pod
./shell.sh      # open a shell inside it
```

## Day to day

| Command | What it does |
|---|---|
| `./shell.sh` | Open a shell in the pod |
| `./status.sh` | Is the pod running? If it is stuck in `Pending`, the events say why (often: no free GPU) |
| `./stop.sh` | Stop the pod and give the GPU back. Please do this when you are not using it for a few days |
| `./start.sh` | Start it again (also after a stop) |

## Adding a package

1. Add it to `requirements.txt` (or `requirements.apt`).
2. Increase `APPVERSION` in `.env`, for example `0.1` -> `0.2`.
3. Run `./build.sh` and then `./start.sh`.

To try a package quickly without rebuilding, run `pip install <package>` inside the pod.
It is gone after the next restart, so add it to `requirements.txt` once you keep it.

## What survives a restart

**Only `/data/`** (your storage volume). Everything else in the
container, including your home folder, is reset to the image whenever the pod
restarts. So:

- Keep your code (a git clone) and results under `/data/...`, in a folder of your own.
- Logins you do inside the pod (`wandb login`, `hf auth login`) are lost on restart.
  Do not put tokens into this repository or into the image.

## Limits

- The pod gets `MEMORY` of RAM (from `.env`). Going over it kills the pod and
  everything running in it. Load large data lazily (`np.load(..., mmap_mode="r")`, data loaders).
- Long trainings: run them inside `tmux` so they keep running when you close your shell
  (`tmux new -s train`, detach with `Ctrl-b d`, back with `tmux attach -t train`).
- GPUs are shared. Stop your pod with `./stop.sh` when you do not need it.

## VS Code

Install the *Kubernetes* and *Dev Containers* extensions, find your pod under
Kubernetes → your cluster → Workloads → Pods, right-click → *Attach Visual Studio Code*.

## TODO

- [ ] **Move the Python environment to a conda env on a persistent volume.**
  New packages would then need no image rebuild, and one image could serve everyone.
  - Image: install miniforge or micromamba and the `requirements.apt` packages, but no Python packages.
    Add a `.zshrc` that activates `$ENV_DIR/envs/main` if it exists.
  - `.env`: add `ENV_DIR=/data/<volume>/<user>/.conda`.
  - New `setup_env.sh`, run inside the pod: create the env on first use, otherwise
    `conda env update --file environment.yml`. Replace `requirements.txt` with `environment.yml`.
  - Also point `HF_HOME`, the pip/conda caches and the wandb `.netrc` at the volume so they survive restarts.
  - Put the env on a block-storage PVC, not an NFS share: conda's many small files are slow on NFS.
  - The env folder must belong to `USER_UID`. Only one pod should use an env at a time.
  - Update the README: "add the package to `environment.yml`, run `./setup_env.sh`".

## Sanity check

After `./start.sh`, open a shell with `./shell.sh` and run these two checks inside the pod.

1. The GPU works:

   ```bash
   python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('GPUs:', torch.cuda.device_count()); print('Name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else '-'); print('Torch', torch.__version__, '| CUDA', torch.version.cuda); x = torch.randn(1000, 1000, device='cuda'); print('Matmul on GPU OK:', (x @ x).shape)"
   ```

   Expected: `CUDA available: True`, `GPUs: 1`, a GPU name and `Matmul on GPU OK: torch.Size([1000, 1000])`.
   If `CUDA available` is `False`, run `nvidia-smi` and ask your supervisor.

2. You can write to your storage:

   ```bash
   touch /data/test && rm /data/test && echo "/data is writable"
   ```

   Expected: `/data is writable`. If you get `Permission denied`, `USER_UID`/`USER_GID` in `.env`
   do not match the owner of the storage volume. Ask your supervisor.
