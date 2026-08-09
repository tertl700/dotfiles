#!/usr/bin/env bash
# Sets up this shell/terminal config on a fresh machine (macOS, Linux, or WSL).
# Idempotent: safe to re-run. Existing files are backed up, never overwritten.
#
#   git clone https://github.com/tertl700/dotfiles.git ~/projects/dotfiles
#   cd ~/projects/dotfiles && ./install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
VIVID_VERSION="0.10.1"

info() { printf '\033[0;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[!]\033[0m %s\n' "$*"; }

# Symlink $1 -> $2, backing up whatever is already at $2.
link() {
  local src="$1" dest="$2"
  [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]] && return 0
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP"
    mv "$dest" "$BACKUP/"
    warn "backed up existing $dest -> $BACKUP/"
  fi
  ln -s "$src" "$dest"
  info "linked $dest"
}

# ---------------------------------------------------------------------------
# 1. Platform + packages
# ---------------------------------------------------------------------------
case "$OSTYPE" in
  darwin*) PLATFORM=macos ;;
  linux*)  PLATFORM=linux ;;
  *) echo "Unsupported OS: $OSTYPE" >&2; exit 1 ;;
esac
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=1 || IS_WSL=0

info "Installing packages ($PLATFORM)..."
if [[ "$PLATFORM" == macos ]]; then
  if ! command -v brew >/dev/null; then
    echo "Homebrew is required. Install it from https://brew.sh, then re-run." >&2
    exit 1
  fi
  # coreutils supplies GNU ls (as `gls`); BSD ls ignores vivid's LS_COLORS.
  brew install zsh git vim curl vivid coreutils
  brew install --cask font-ubuntu-mono || warn "font cask skipped (already present?)"
  brew install --cask ghostty || warn "ghostty cask skipped (already installed?)"
else
  sudo apt-get update
  sudo apt-get install -y zsh git vim curl

  # vivid isn't in Ubuntu's repos; grab the release .deb if apt can't supply it.
  if ! command -v vivid >/dev/null; then
    if ! sudo apt-get install -y vivid 2>/dev/null; then
      arch="$(dpkg --print-architecture)"
      deb="vivid_${VIVID_VERSION}_${arch}.deb"
      info "Installing vivid $VIVID_VERSION from GitHub releases..."
      curl -fsSLo "/tmp/$deb" \
        "https://github.com/sharkdp/vivid/releases/download/v${VIVID_VERSION}/${deb}"
      sudo dpkg -i "/tmp/$deb"
      rm -f "/tmp/$deb"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 2. oh-my-zsh + plugins
# ---------------------------------------------------------------------------
if [[ ! -d "$ZSH_DIR" ]]; then
  info "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  info "Installing zsh-syntax-highlighting..."
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ---------------------------------------------------------------------------
# 3. Symlinks
# ---------------------------------------------------------------------------
link "$DOTFILES/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/.aliases" "$HOME/.aliases"
link "$DOTFILES/.vimrc"   "$HOME/.vimrc"

# Custom themes override oh-my-zsh built-ins, so updates can't clobber this.
link "$DOTFILES/eastwood.zsh-theme" "$ZSH_CUSTOM/themes/eastwood.zsh-theme"
link "$DOTFILES/colors/smyck.vim"   "$HOME/.vim/colors/smyck.vim"
link "$DOTFILES/terminal/ghostty.config" "$HOME/.config/ghostty/config"

# ---------------------------------------------------------------------------
# 4. Default shell
# ---------------------------------------------------------------------------
zsh_path="$(command -v zsh)"
if [[ "${SHELL:-}" != "$zsh_path" ]]; then
  info "Setting zsh as the default shell..."
  grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$zsh_path" || warn "chsh failed; run 'chsh -s $zsh_path' by hand."
fi

# ---------------------------------------------------------------------------
# 5. Windows Terminal (WSL only) — a copy, not a symlink: it lives on the
#    Windows side and Windows Terminal won't follow a symlink out of /mnt/c.
# ---------------------------------------------------------------------------
if [[ "$IS_WSL" == 1 ]]; then
  wt_dir="$(ls -d /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState 2>/dev/null | head -1 || true)"
  if [[ -n "$wt_dir" ]]; then
    info "Windows Terminal found at $wt_dir"
    if [[ -f "$wt_dir/settings.json" ]]; then
      mkdir -p "$BACKUP"
      cp "$wt_dir/settings.json" "$BACKUP/windows-terminal-settings.json"
      warn "backed up existing Windows Terminal settings -> $BACKUP/"
    fi
    cp "$DOTFILES/terminal/windows-terminal.json" "$wt_dir/settings.json"
    info "Installed Windows Terminal settings."
    warn "If the Ubuntu profile looks wrong, the WSL guid differs on this machine."
    warn "Copy it from Settings -> Ubuntu into terminal/windows-terminal.json."
  else
    warn "Windows Terminal not found; skipped its settings."
  fi
fi

echo
info "Done. Open a new terminal (or run: exec zsh)."
[[ -d "$BACKUP" ]] && info "Backups of replaced files: $BACKUP"
exit 0
