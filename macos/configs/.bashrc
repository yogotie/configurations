#!/usr/bin/env bash

# =============================================================================
# Terminal & Path additions/edits/exports
# =============================================================================

# Source global definitions if existent
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# Some distros make use of a profile.d script to import completion
if [ -f /etc/profile.d/bash_completion.sh ]; then
  . /etc/profile.d/bash_completion.sh
fi

# On macOS, load brew bash completion modules
BREW_PREFIX=$(brew --prefix)
if [ -f "$BREW_PREFIX"/etc/bash_completion ]; then
  . "$BREW_PREFIX"/etc/bash_completion
fi

if [ "${BASH_VERSINFO}" -ge 4 ] && [ -f "$BREW_PREFIX"/share/bash-completion/bash_completion ]; then
  . "$BREW_PREFIX"/share/bash-completion/bash_completion
fi

# =============================================================================
# Terminal & Path additions/edits/exports
# =============================================================================

# customize PS1 bash prompt and change if on remote machine over SSH:
#   SSH: bold w/red user@host and yellow pwd $
#   Local: bold w/blue user@host and yellow pwd $

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ -n "$SSH_CLIENT" ]; then
  export PS1="\[\e[1;31m\][SSH]\u@\h \[\e[1;33m\]\W $\[\e[0m\] "
else
  export PS1="\[\e[1;34m\]\u@\h \[\e[1;33m\]\W\[\e[0m\]\$(parse_git_branch)\[\033[00m\] $ "
#  export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
fi

# set vim as default editor
export VISUAL=vim
export EDITOR="$VISUAL"

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr
export PYTHONIOENCODING='UTF-8'

# enable more advanced globbing in bash
shopt -s globstar

# autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# Append to bash history file rather than overwriting it
shopt -s histappend

# keep more bash history
export HISTSIZE=10000
export HISTFILESIZE=120000

# Omit duplicates and commands that begin with a space from bash history
export HISTCONTROL='ignoreboth'

# Prefer US English and use UTF-8
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}"

# Don’t clear the screen after quitting a manual page
export MANPAGER='less -X'

if [ "$(uname -s)" = "Linux" ]; then
  #               - Linaro build tools
  export PATH=$PATH:~/./src/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin

  # Prevent ioctl error when gpg2 signing
  export GPG_TTY=$(tty)

  # Enable GCC 8 & LLVM 7 in CentOS
  if [ -f /etc/centos-release ]; then
    source scl_source enable devtoolset-8 llvm-toolset-7
  fi

elif [ "$(uname -s)" = "Darwin" ]; then
  export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  export PATH=$PATH:/usr/local/bin
fi


# =============================================================================
# User specific aliases and functions
# =============================================================================

# set terminal since other machines likely don't have our funky term settings
alias ssh='TERM=xterm-256color ssh'

# explicitly alias vi->vim & use `vimx` in Fedora
if command -v vimx > /dev/null; then
  alias vi='vimx'
  alias vim='vimx'
else
  alias vi='vim'
fi

# easy updating for package management
if [ "$(uname -s)" = "Linux" ]; then
  if [ -n "$(command -v yum)" ]; then
    alias sys-update='sudo yum upgrade -y && echo "" > /tmp/sys_package_updates'
  fi
elif [ "$(uname -s)" = "Darwin" ]; then
  alias sys-update='brew update && brew upgrade && brew cleanup && echo "" > /tmp/sys_package_updates'
fi

# ls macros
# alias ll='ls -lhXG'
# alias ls='ls --color=auto'
# alias lsa='ls -A --color=auto'
# alias lsn='ls -a --color=no'
# alias lsd="ls -alF | grep /$"

# color grep by default
alias grep='grep --color=auto'

# allow `cd..` typo for `cd ..`
alias cd..='cd ..'

# allow for typo of `cd -` previous cmd (and suppress output since we're toggling
# back and forth a previous directory not examing the stack like in push/popd)
alias cd-='cd - > /dev/null'

# cd to root directory of git repo (or submodule)
alias cdg='cd "$(git rev-parse --show-toplevel)"'

# pushd to root directory of git repo (or submodule)
alias pdg='pushd "$(git rev-parse --show-toplevel) > /dev/null"'

# Clean output of directory size usage
alias duh='du -h -d 1 | sort -bh'

# type less for faster push/pop dirs
alias p='pushd'
alias o='popd'
alias d='dirs -v'

# clear screen and ls with one command
alias cls='clear && ls'

# start calculator with math support
alias bc='bc -l'

# tmux should assume 256 color terminal support
alias tmux='tmux -2'

# create daily logbook
function lb() {
  mkdir -p ~/logbook
  StrDate=$(date '+%m-%d-%Y')
  StrPath=~/logbook/$StrDate.md
  touch "$StrPath"
  echo "# Logbook for $StrDate" > "$StrPath"
  echo "## Problem/Situation"  >> "$StrPath"
  echo "## Hypothesis"         >> "$StrPath"
  echo "## Experiment"         >> "$StrPath"
  echo "## Outcome"            >> "$StrPath"
  vim "$StrPath"
}

# <tab> completion for "Makefile"s in a dir showing all options as well
complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make


# =============================================================================
# Cleanup & Launches
# =============================================================================

# Run tmux automatically if not in SSH session and not already launched
# Attach to `dev` session if existent, else launch session `dev`
if [ -z "$TMUX" ] && [ -z "$SSH_CLIENT" ]; then
  tmux new-session -A -s dev
fi

