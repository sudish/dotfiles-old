# zsh init file

# A lot of things are conditionalized on $uname
uname=$(uname)

# Load various startup files, prioritized by name
for zsfile in ~/.zshinit/S[0-9][0-9]_*; do
    source $zsfile
done

# Additional locations for functions and completions
fpath+=~/.zcompletions

# These lead to sundry madness under Linux, just say No! for now.
[[ $uname = Linux ]] && unset LANG LC_ALL LC_CTYPE LC_COLLATE


# prompt string
if [[ $TERM = dumb ]]; then
    PROMPT='%# '
else
    # Classic UNIX prompt on the left
    PROMPT='%B%#%b '

    # Information overload on the right
    RPROMPT="%B%m:%~%b"
    RPROMPT+="%(?..%B[%b$cb[red]%?$cb[none]%B]%b)" # Exit status of last job
    RPROMPT+="%(1j:$cb[magenta][+]$cb[none]:)" # Are there backgrounded jobs?
    RPROMPT+=' $(sj_git_ps1)'	   # VCS status info for pwd
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

# zsh options.  some of these are defaults and should be pruned
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
    pushd_to_home sun_keyboard_hack transient_rprompt 2>/dev/null
unsetopt bg_nice bsd_echo chase_links correct_all list_ambiguous \
    mail_warning multi_func_def xxx 2>/dev/null
DIRSTACKSIZE=20
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$HOME/.history_zsh
SELECTMIN=0

# Options for various programs
PAGER=less
EDITOR=vi
VISUAL=vi
#LESS=-R
PROCMAILOG=$HOME/Mail/log.procmail
MYSQL_PS1='\u@\h/\d> '
VERSION_CONTROL=existing	# GNU patch

# enable color ls o/p
LS_COLOR_OPTS='--color=tty'
ls $LS_COLOR_OPTS >&| /dev/null || unset LS_COLOR_OPTS
[[ $uname = Darwin ]] && CLICOLOR=y # Enable color in OS X ls

# enable color grep/ack o/p
GREP_COLOR_OPTS='--color=auto'
grep $GREP_COLOR_OPTS localhost /etc/hosts >&| /dev/null || \
    unset GREP_COLOR_OPTS
ACK_COLOR_MATCH='bold red'

# X11 for OS X doesn't set the fully qualified DISPLAY name
[[ $uname = Darwin && -n $DISPLAY ]] && export DISPLAY=:0.0

# Java under OS X
[[ $uname = Darwin ]] && \
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

if [[ $uname = Solaris ]] ; then
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

#autoload -U promptinit
#promptinit

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
compinit -u
# End of lines added by compinstall
