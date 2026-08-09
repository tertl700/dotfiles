# eastwood, with customized colors. Loaded from oh-my-zsh's custom/themes/,
# which overrides the built-in of the same name and survives omz updates.
#
#   *[main][~/projects]$
#    │ └ branch #bad761   └ path #9cd1bb
#    └ dirty marker #ffd76d
#
# Uses %F/%f rather than $reset_color so zsh tracks the active color itself.
# Mixing the two leaves the prompt's color bleeding into whatever you type.

ZSH_THEME_GIT_PROMPT_PREFIX="%F{#bad761}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{#ffd76d}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# oh-my-zsh can't render the dirty marker before the branch name, so build the
# git segment by hand.
git_custom_status() {
  local cb
  cb=$(git_current_branch)
  if [[ -n "$cb" ]]; then
    echo "$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_PREFIX}${cb}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
  fi
}

PROMPT='$(git_custom_status)%F{#9cd1bb}[%~]%B$%b%f '
