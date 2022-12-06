echo  $(TZ=":America/Caracas" date +'%Y-%m-%d_%H%M%S')" ${0}" >> ~/Arranque_bash.log
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# Para recargar ediciones a este archivo, ejecutar
# source ~/.bashrc

# http://tldp.org/LDP/abs/html/comparison-ops.html
#       [ -z "$algo" ]     True si $algo es Null (string de longitud cero)
#       [ -n "$algo" ]     True si $algo es NO Null
#       [ -r /algun/arch ] True si /algun/arch es un archivo legible (readable)

# PS1 es el prompt de la sesion
#  Si no existe (es Null) no es sesion interactiva en pantalla,
#  no configurar mas nada de esta sesion
  [ -z "$PS1" ] && return

########## CONFIGURACION DEL HISTORY ##########
# Don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
  HISTCONTROL=ignoredups:erasedups
# append to the history file, don't overwrite it
  shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=1000
  HISTFILESIZE=2000
# Time tag history
  export HISTTIMEFORMAT="%h%d %H:%M:%S "
# Ignore Specific Commands
  export HISTIGNORE="history:otrocomando:cualquierotro"
# Store multi-line commands in one history entry:
  shopt -s cmdhist
# append and reload the history after each command
  PROMPT_COMMAND="history -a; history -n"
################################################

########## DEFINICIONES DE ALIASES ##########
# Es mas ordenado poner los aliases en otro archivo
#  Lo normal es ~/.bash_aliases, pero se puede poner en otro lado
#  por ejemplo un archivo de aliases comunes a todos los usuarios
# Ver /usr/share/doc/bash-doc/examples
# Incluir .bash_aliases sin ver si existe,
#  justamente para que de un error si no existe
. /etc/0-bashStandard/.bash_aliases
################################################

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
  shopt -s checkwinsize

########## AGREGAR EL CHROOT AL PROMPT ##########
# Si este shell esta dentro de un chroot (directorio raiz a partir de un sub-dir)
#  y si ese directorio raiz tiene un archivo /etc/debian_chroot
#  y la variable debian_chroot esta vacia, tomarla del archivo
#  para mostrarla en el prompt
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
################################################

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
#    alias ls='ls --color=auto'
#    alias grep='grep --color=auto'
#    alias fgrep='fgrep --color=auto'
#    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

if [ -f "$HOME/.bash_ps1" ]; then
  . "$HOME/.bash_ps1"
fi

# Si es root, que el prompt sea rojo, si no que sea azul:
if [ "`id -u`" -eq 0 ]; then
#  PS1='# '
   PS1="\[\e[1;31;43;40m\]\u \h \w \n#\[\e[00m\] "
   else
#  PS1='$ '
   PS1="\[\e[1;36m\]\u \h \w \n\$\[\e[00m\] "
fi
# Agregar la campanita para que avise al terminar comandos largos
PS1=$PS1$(printf "\007")

