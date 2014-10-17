# root dir for sundry zsh things
ZDIR=~/.zsh.d

# set up fink env
[[ -f /sw/bin/init.sh ]] && . /sw/bin/init.sh

# set up rvm
#if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
#    source "$HOME/.rvm/scripts/rvm" >/dev/null 2>&1
#    sj_rvm_present=1
#fi

# set up homebrew-specific paths only if under OS X
if [[ `uname` = Darwin ]]; then
    brew=/usr/local/bin/brew
    if [[ -x $brew ]]; then
        BREWPATH=$($brew --prefix coreutils)/libexec/gnubin
    fi
fi

[[ -r /etc/environment ]] && source /etc/environment

# Set a reasonable path
unsetopt ksh_arrays
path=(
    ~/src/apache-maven-3.2.3/bin
    ~/bin
    $ZDIR/external/autojump/bin
    ~/.cabal/bin
    ~/.nodejs/bin
    ~/.rbenv/bin
    #~/.rvm/bin
    ~/.virtualenv/bin
    /usr/local/share/python
    ${(s.:.)${BREWPATH}}
    /usr/local/sbin
    /usr/local/bin
    /sw/sbin
    /sw/bin
    /opt/local/lib/postgresql83/bin
    /opt/local/apache2/bin
    /opt/local/sbin
    /opt/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    "$path[@]"
)
typeset -U path			# delete duplicates
path=($^path(N-/))		# remove nonexistent dirs
unset BREWPATH

# Set MANPATH from man's config, since fink, for e.g., mucks with it
if [[ `uname` = Darwin ]]; then
    if `which manpath >/dev/null 2>&1`; then
        MANPATH=`manpath`
    fi
fi

# init rbenv
[[ -d /opt/rbenv ]] && RBENV_ROOT=/opt/rbenv
if whence rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
    sj_rbenv_present=1
fi
