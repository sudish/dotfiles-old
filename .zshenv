# set up fink env
[[ -f /sw/bin/init.sh ]] && . /sw/bin/init.sh

# Set a reasonable path, remove dirs that don't exist on this machine
unsetopt ksh_arrays
d=( ~/bin
    ~/.cabal/bin
    /var/lib/gems/1.8/bin
    /sw/sbin
    /sw/bin
    /opt/local/lib/postgresql83/bin
    /opt/local/apache2/bin
    /opt/local/sbin
    /opt/local/bin
    /usr/local/sbin
    /usr/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
   ${(s.:.)${PATH}} )       # zsh pukes if i do this in a typeset
typeset -U d                # delete duplicates
s=()
for dir in "$d[@]"; do      # delete nonexistent dirs
    [[ -d $dir && $dir != '.' ]] && s=($s $dir)
done
PATH=${(j.:.)${s}}
unset d s dir

# Set MANPATH from man's config, since fink, for e.g., mucks with it
if [[ `uname` = Darwin ]]; then
    if `which manpath >/dev/null 2>&1`; then
        unset MANPATH
        MANPATH=`/usr/libexec/path_helper | sed -ne 's/^MANPATH="\(.*\)".*/\1/p'`
    fi
fi
