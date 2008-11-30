# Set a reasonable path, remove dirs that don't exist on this machine
unsetopt ksh_arrays
d=( ~/bin `cat ~/.sj-config/PATH`
   ${(s.:.)${PATH}} )       # zsh pukes if i do this in a typeset
typeset -U d                # delete duplicates
s=()
for dir in "$d[@]"; do      # delete nonexistent dirs
    [[ -d $dir && $dir != '.' ]] && s=($s $dir)
done
PATH=${(j.:.)${s}}
unset d s dir
