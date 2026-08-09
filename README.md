# dotfiles

Terminal setup for WSL/Ubuntu, Linux, and macOS: zsh + oh-my-zsh, a customized
`eastwood` prompt, One Half Dark colors, and vim.

```sh
git clone https://github.com/tertl700/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles && ./install.sh
```

`install.sh` is idempotent. Anything it replaces is backed up to
`~/.dotfiles-backup/<timestamp>/` first.

## What's here

| File | Installed to |
| --- | --- |
| `.zshrc` | `~/.zshrc` (symlink) |
| `.aliases` | `~/.aliases` (symlink) |
| `.vimrc` | `~/.vimrc` (symlink) |
| `eastwood.zsh-theme` | `~/.oh-my-zsh/custom/themes/` (symlink) |
| `colors/smyck.vim` | `~/.vim/colors/` (symlink) |
| `terminal/ghostty.config` | `~/.config/ghostty/config` (symlink) |
| `terminal/windows-terminal.json` | Windows Terminal `settings.json` (**copy**, WSL only) |

Everything is symlinked, so editing `~/.zshrc` edits the repo — no drift.
Windows Terminal is the exception: its settings live on the Windows side and it
won't follow a symlink out of `/mnt/c`, so that one is copied.

## The prompt

```
*[main][~/projects]$
 └ dirty marker, then branch, then path
```

From `eastwood.zsh-theme`, with the colors customized:

| Element | Color |
| --- | --- |
| Branch `[...]` | `#bad761` green |
| Dirty `*` | `#ffd76d` yellow |
| Path `[~/...]` | `#9cd1bb` teal |

It lives in oh-my-zsh's `custom/themes/` rather than `themes/`. Custom themes
override built-ins of the same name, so oh-my-zsh updates can't overwrite these
edits — which is exactly what would have happened editing the original in place.

**No Nerd Font required.** The prompt uses only `[`, `]`, `*`, and `$` — zero
powerline glyphs. Any monospace font works, on any machine.

## Colors

One Half Dark (`#282c34` background, `#dcdfe4` foreground) everywhere:

- **Windows Terminal** — ships with the scheme built in, so `schemes` is empty.
- **Ghostty** — full palette written out explicitly in `terminal/ghostty.config`.
- **`ls`** — molokai palette via [vivid](https://github.com/sharkdp/vivid).
- **vim** — smyck, vendored at `colors/smyck.vim`.

## Per-machine notes

**Windows Terminal GUIDs.** `defaultProfile` and the Ubuntu profile's `guid` are
generated per machine from the installed distro. If the Ubuntu profile looks
wrong after installing, copy the guid from Settings → Ubuntu into
`terminal/windows-terminal.json` (both places).

**vivid on Ubuntu.** Not in the apt repos; `install.sh` pulls the `.deb` from
GitHub releases. `.zshrc` degrades gracefully if it's missing — you just get
default `ls` colors.

**Local overrides.** `~/.zshrc.local` is sourced at the end of `.zshrc` if it
exists. Put machine-specific things (API keys, work paths) there — it's not
tracked by this repo.
