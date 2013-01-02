#!/bin/sh

ext_dir=.zsh.d/external
branch=master

function update_subtree {
  subtree=$1
  remote=$2

  git subtree pull -m "Update subtree: $subtree" --squash -P $ext_dir/$subtree $remote $branch
}

update_subtree autojump                git://github.com/joelthelion/autojump
update_subtree git-flow-completion     git://github.com/bobthecow/git-flow-completion
update_subtree z                       git://github.com/rupa/z.git
update_subtree zaw                     git://github.com/zsh-users/zaw.git
update_subtree zsh-completions         git://github.com/zsh-users/zsh-completions.git
update_subtree zsh-syntax-highlighting git://github.com/zsh-users/zsh-syntax-highlighting.git
