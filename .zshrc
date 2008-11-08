# zsh init file       -*- ksh -*-

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

# These lead to sundry madness under Linux, just say No! for now.
unset LANG LC_ALL LC_CTYPE LC_COLLATE

# Portable zsh color prompt hackery!
# Obtained from http://aperiodic.net/phil/prompt/prompt.txt
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
  colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
  eval SJ_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
  eval SJ_LIGHT_$color='%{$fg[${(L)color}]%}'
  (( count = $count + 1 ))
done
SJ_NO_COLOR="%{$terminfo[sgr0]%}"


# prompt string
PROMPT='%B%#%b '
RPROMPT='$SJ_GREEN%m$SJ_NO_COLOR%B:%b$SJ_BLUE%~$SJ_NO_COLOR%(?..[$SJ_RED%B%?%b$SJ_NO_COLOR])%(1v:[$SJ_RED%B+%b$SJ_NO_COLOR]:)'

# check for backgrounded jobs
set_psvar () {
    if jobs % >& /dev/null; then
    psvar=("")
    else
    psvar=()
    fi
}

precmd () {
    set_psvar
}

bindkey -e
bindkey ' ' magic-space
bindkey '' backward-delete-char
bindkey '' backward-delete-char
bindkey '[A' history-search-backward
bindkey '[B' history-search-forward

# some of these are defaults and should be pruned
setopt \
  allexport always_last_prompt always_to_end append_history auto_list auto_menu \
  auto_name_dirs auto_param_keys auto_param_slash auto_pushd auto_remove_slash \
  check_jobs complete_aliases complete_in_word correct extended_glob \
  extended_history hash_cmds hash_list_all hist_allow_clobber hist_find_no_dups \
  hist_ignore_all_dups hist_ignore_dups hist_no_store hist_reduce_blanks \
  hist_save_no_dups inc_append_history kshoptionprint list_beep list_packed \
  list_types long_list_jobs magic_equal_subst mark_dirs no_clobber no_no_match \
  prompt_subst pushd_ignore_dups pushd_minus pushd_silent pushd_to_home \
  sun_keyboard_hack transient_rprompt
unsetopt bg_nice bsd_echo mail_warning chase_links correct_all list_ambiguous
DIRSTACKSIZE=20
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.history_zsh
#MAILCHECK=300
#MAILPATH="/usr/spool/mail/$LOGNAME?New Mail."
SELECTMIN=0
PAGER=less
#LESS=-R

##
EDITOR=vi
VISUAL=vi
ENSCRIPT='-BL 66'
PROCMAILOG=$HOME/Mail/log.procmail
PGPPATH=$HOME/lib/.pgp
MYSQL_PS1='\u@\h/\d> '

# enable color ls o/p
LS_COLOR_OPTS="--color=tty"
ls $LS_COLOR_OPTS >/dev/null 2>&1 || LS_COLOR_OPTS=""
[[ `uname` == 'Darwin' ]] && CLICOLOR=y

# X11 for OS X doesn't set the fully qualified DISPLAY name
[[ `uname` == Darwin && -n "$DISPLAY" ]] && export DISPLAY=:0.0

# GNU patch
VERSION_CONTROL=existing

# Java under OS X
[ `uname` = Darwin ] && JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

# miscellaneous functions
l  ()       { ls $LS_COLOR_OPTS -al $* }
lh ()       { ls $LS_COLOR_OPTS -alh $* }
lf ()       { ls $LS_COLOR_OPTS -F $* }

# push long, commonly used, commands into the edit buffer to save typing
sj_configure () {
  for i in . .. ; do
    [[ -x $i/configure ]] && { echo $i/configure; return; }
  done
  echo "Couldn't find configure in ./ or ../" 1>&2
  echo could_not_locate_configure
}
sjcc () {
  print -z 'CC=gcc CXX=g++ CFLAGS="-O2 -pipe -Wall" CXXFLAGS=$CFLAGS' `sj_configure` '--verbose --help'
}
sjlcc () {
  print -z 'CC=gcc CXX=g++ CFLAGS="-O2 -pipe -Wall" CXXFLAGS=$CFLAGS CPPFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib -R/usr/local/lib"' `sj_configure` '--verbose --help'
}
sjemacsconfigure () {
  print -z 'CC=gcc CXX=g++ CFLAGS="-O2 -pipe -Wall" CXXFLAGS=$CFLAGS' `sj_configure` '--verbose --enable-cocoa-experimental-ctrl-g --without-pop --without-x --with-x-toolkit=no --with-ns'
}

##
# aliases
alias ls="ls $LS_COLOR_OPTS -F" j='jobs -lp' m='less -R' md=mkdir
alias s=screen d='dirs -v' wh='whence -csa' bc='bc -l'
alias h=history hs='fc -RI'

expr "$OSTYPE" : ".*[Bb][Ss][Dd].*" >/dev/null 2>&1 && alias make=gmake
if expr "$OSTYPE" : "[Ss]olaris.*" >/dev/null 2>&1 ; then
  alias ping='ping -s'
  alias tnetstat='netstat -f inet -P tcp'
fi

# shortcut definitions
test -r ~/.zdirs  && source ~/.zdirs
test -r ~/.zhosts && source ~/.zhosts

# color_xterm needs to be told the hard way
#ttyctl -u
#stty 38400 imaxbel iexten echoctl echoke \
#     werase '^W'  lnext '^V'  intr '^C'  quit '^\'  erase '^?'  \
#     kill   '^U'  eof '^D'    susp '^Z'  stop '^S'  start '^Q'
#ttyctl -f

# Timezone (`EST5EDT' is the POSIX version)
TZ=EST5EDT

# Use keychain to start and manage ssh-agent
if [[ `whoami` == 'sj' || `whoami` == 'sudish' ]]; then
  kcfiles=()
  for file in {id,damballa}_{dsa,rsa} ; do
    [[ -r ~/.ssh/$file ]] && kcfiles+="$file"
  done
  sj_keyhost=sudish # use a fixed hostname, no nfs here
  if [[ -n "$kcfiles" ]] ; then
    keychain --agents ssh --host "$sj_keyhost" -q "$kcfiles[@]"
    source "$HOME/.keychain/${sj_keyhost}-sh"
  else
    fgrep ForwardAgent ~/.ssh/config >/dev/null 2>&1 || \
      echo "No ForwardAgent or ssh keyfiles for keychain!"
  fi
  unset kcfiles file
fi

autoload -U promptinit
promptinit

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'l:|=* r:|=*' 'r:|[._-]=** r:|=**' 'm:{a-z}={A-Z}'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' original false
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle :compinstall filename '~.zcomp'

autoload -Uz compinit
compinit
# End of lines added by compinstall

### Local Variables:
### auto-fill-function: nil
### End:
