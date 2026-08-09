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
# Auto-activate .venv when entering a directory that has one
# -------------------------------------------------------------------
autoload -Uz add-zsh-hook

_auto_venv() {
  if [[ -f "$PWD/.venv/bin/activate" ]]; then
    source "$PWD/.venv/bin/activate"
  elif [[ -n "$VIRTUAL_ENV" && "$PWD" != "$VIRTUAL_ENV"* ]]; then
    deactivate
  fi
}

add-zsh-hook chpwd _auto_venv
_auto_venv  # run on shell start too

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
