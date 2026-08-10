# ~/.zshrc — managed by github.com/tertl700/dotfiles (symlinked by install.sh)

export ZSH="$HOME/.oh-my-zsh"

# Loaded from $ZSH_CUSTOM/themes/eastwood.zsh-theme, which install.sh symlinks
# to this repo. Custom themes win over built-ins, so oh-my-zsh updates can't
# clobber the customized colors.
ZSH_THEME="eastwood"

# zsh-syntax-highlighting must stay last.
plugins=(git zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# -------------------------------------------------------------------
# ls colors — molokai via https://github.com/sharkdp/vivid
# -------------------------------------------------------------------
if command -v vivid >/dev/null 2>&1; then
  export LS_COLORS="$(vivid generate molokai)"
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# -------------------------------------------------------------------
# Python
# -------------------------------------------------------------------
# Projects are uv-managed: `uv run` syncs and runs in ./.venv on its own, so
# there's no chpwd hook activating envs. This only matters for the occasional
# manual `source .venv/bin/activate` — it stops that script prepending its
# unstyled "(name) " to PS1, where the name is either ".venv" or a repeat of
# the path the prompt already shows.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# -------------------------------------------------------------------
# PATH
# -------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS) — Apple Silicon and Intel prefixes.
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
fi

# Machine-specific settings that shouldn't be committed (API keys, work paths).
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
