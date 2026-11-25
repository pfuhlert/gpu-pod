# GPU development container for the IMSB Kubernetes cluster.
# You normally do not need to edit this file: add packages to
# requirements.apt (system) and requirements.txt (Python) instead.
FROM docker.io/pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

ARG DEBIAN_FRONTEND=noninteractive

# System packages: the ones from requirements.apt plus a few the image needs itself.
COPY requirements.apt /tmp/requirements.apt
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      $(grep -v '^\s*#' /tmp/requirements.apt | tr '\n' ' ') \
      sudo git wget curl ca-certificates zsh \
 && rm -rf /var/lib/apt/lists/* /tmp/requirements.apt

# Non-root user. Values come from .env through build.sh.
ARG USERNAME
ARG USER_UID
ARG USER_GID
RUN groupadd --gid "$USER_GID" "$USERNAME" \
 && useradd --uid "$USER_UID" --gid "$USER_GID" -m -s /usr/bin/zsh "$USERNAME" \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME" \
 && chmod 0440 "/etc/sudoers.d/$USERNAME"

USER $USERNAME
ENV HOME=/home/$USERNAME
WORKDIR /home/$USERNAME
ENV PATH=/home/$USERNAME/.local/bin:$PATH

# Oh My Zsh (nicer shell; remove these lines if you prefer bash).
RUN sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# Prompt: user@pod-name:folder (see prompt.zsh).
COPY --chown=$USERNAME prompt.zsh /home/$USERNAME/.zsh_prompt
RUN echo 'source ~/.zsh_prompt' >> ~/.zshrc

# Git identity (from .env).
ARG GIT_NAME
ARG GIT_EMAIL
RUN git config --global user.name "$GIT_NAME" \
 && git config --global user.email "$GIT_EMAIL" \
 && git config --global pull.ff only

# Python packages.
COPY --chown=$USERNAME requirements.txt /tmp/requirements.txt
RUN python -m pip install --no-cache-dir --upgrade pip \
 && python -m pip install --no-cache-dir -r /tmp/requirements.txt

CMD ["sleep", "infinity"]
