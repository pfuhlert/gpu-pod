# Shell prompt, loaded at the end of ~/.zshrc. Shows: user@pod-name:folder (git branch) $
# A green arrow means the last command worked, a red one that it failed.
PROMPT='%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜) %{$fg_bold[cyan]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%} $(git_prompt_info)%{$reset_color%}$ '
