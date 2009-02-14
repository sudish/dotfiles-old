# zsh init file       -*- ksh -*-

emulate zsh

source ~/.zfunc/S[0-9]*_*

# These lead to sundry madness under Linux, just say No! for now.
[[ `uname` = Linux ]] && unset LANG LC_ALL LC_CTYPE LC_COLLATE

# hooks run before/on/after each command
set_psvar () {
    if jobs % >& /dev/null; then
	psvar=("")
    else
	psvar=()
    fi
}

# zsh per-command hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_psvar

# zsh provides color codes, nice
autoload colors zsh/terminfo
if [[ $terminfo[colors] -ge 8 ]]; then
  colors
fi

# prompt string
if [[ $TERM = dumb ]]; then
    PROMPT='%# '
else
    PROMPT='%B%#%b '
    RPROMPT='%B%m:%~%(?..[%F{red}%?%f])%(1v:[%F{red}+%f]:)%b'
    RPROMPT+=' $(sj_git_ps1)'
fi

bindkey -e
bindkey ' ' magic-space
bindkey '' backward-delete-char
bindkey '' backward-delete-char
bindkey '[A' history-search-backward
bindkey '[B' history-search-forward

# zsh built-in help system (bound to ESC h by default)
unalias run-help
autoload -Uz run-help

# some of these are defaults and should be pruned
setopt \
    allexport always_last_prompt always_to_end append_history auto_list \
    auto_menu auto_name_dirs auto_param_keys auto_param_slash auto_pushd \
    auto_remove_slash check_jobs complete_aliases complete_in_word \
    correct extended_glob extended_history hash_cmds hash_list_all \
    hist_allow_clobber hist_find_no_dups hist_ignore_all_dups \
    hist_ignore_dups hist_no_store hist_reduce_blanks hist_save_no_dups \
    inc_append_history kshoptionprint list_beep list_packed \
    list_types long_list_jobs magic_equal_subst mark_dirs no_clobber \
    no_no_match prompt_subst pushd_ignore_dups pushd_minus pushd_silent \
    pushd_to_home sun_keyboard_hack transient_rprompt
unsetopt bg_nice bsd_echo chase_links correct_all list_ambiguous \
    mail_warning multi_func_def
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
[[ `uname` = Darwin ]] && CLICOLOR=y

# enable color grep o/p
GREP_COLOR_OPTS="--color=auto"
grep $GREP_COLOR_OPTS local /etc/hosts >/dev/null 2>&1 || GREP_COLOR_OPTS=""

# X11 for OS X doesn't set the fully qualified DISPLAY name
[[ `uname` = Darwin && -n $DISPLAY ]] && export DISPLAY=:0.0

# GNU patch
VERSION_CONTROL=existing

# Java under OS X
[[ `uname` = Darwin ]] && \
    JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

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
  print -z 'CC=gcc-4.2 CXX=g++-4.2 CFLAGS="-O2 -pipe -Wall" CXXFLAGS=$CFLAGS' `sj_configure` '--verbose --help'
}

##
# aliases
alias  grep="grep $GREP_COLOR_OPTS"
alias fgrep="fgrep $GREP_COLOR_OPTS"
alias egrep="egrep $GREP_COLOR_OPTS"
alias ls="ls $LS_COLOR_OPTS -F"
alias j='jobs -lp' m='less -R' md=mkdir
alias s=screen d='dirs -v' wh='whence -csa' bc='bc -l'
alias h=history hs='fc -RI'
alias lsrebuild='/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user'
alias ec='emacsclient -nc'

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
  for file in {id,github,damballa}_{dsa,rsa} ; do
    [[ -r ~/.ssh/$file ]] && kcfiles+="$file"
  done
  sj_keyhost=sudish # use a fixed hostname, no nfs here
  if [[ -n $kcfiles ]] ; then
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
zstyle :compinstall filename '~/.zcomp'

autoload -Uz compinit
compinit
# End of lines added by compinstall
