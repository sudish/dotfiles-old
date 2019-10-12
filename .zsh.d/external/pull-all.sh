#!/bin/sh

# must run from root of repo
gitroot=`git rev-parse --show-toplevel 2>/dev/null`
cd $gitroot || (echo "Can't chdir to git root: $gitroot"; exit 1)

ext_dir=.zsh.d/external
branch=master

function update_subtree {
  subtree=$1
  remote=$2
  dir=${3:-$ext_dir}

  git subtree pull -m "Update subtree: $subtree" --squash -P $dir/$subtree $remote $branch
}

update_subtree autojump                     git://github.com/wting/autojump
update_subtree git-flow-completion          git://github.com/bobthecow/git-flow-completion
update_subtree z                            git://github.com/rupa/z.git
update_subtree zaw                          git://github.com/zsh-users/zaw.git
update_subtree zsh-autosuggestions          git://github.com/zsh-users/zsh-autosuggestions
update_subtree zsh-completions              git://github.com/zsh-users/zsh-completions.git
update_subtree zsh-git-prompt               git://github.com/olivierverdier/zsh-git-prompt.git
update_subtree zsh-history-substring-search git://github.com/zsh-users/zsh-history-substring-search.git
update_subtree zsh-syntax-highlighting      git://github.com/zsh-users/zsh-syntax-highlighting.git

update_subtree dracula                      git://github.com/dracula/vim.git .vim/pack/themes/start
