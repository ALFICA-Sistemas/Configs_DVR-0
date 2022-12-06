alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -Al'

alias carpetas='smbclient -L $(hostname) -U '$1
alias puertos='sudo netstat -tulpn | grep LISTEN'
alias mkdir="mkdir -pv"
alias hg='history | grep $@'
alias hn='history $1'
alias servicios='ll /etc/systemd/system/ && ll /lib/systemd/system/'
alias repos='ll /etc/apt/sources.list.d/'
alias hosts='sudo nano /etc/hosts'

websrv () {
  curl -s -I $1 | grep Server
}

denadie () {
  sudo chown -R nobody $1 &&
  sudo chgrp nogroup -R $1 &&
  sudo chmod 777 -R $1
}

solomio () {
   sudo chown -R $(whoami) $1 &&
   sudo chgrp nogroup -R $1 &&
   sudo chmod 744 -R $1
}

clave () {
  sudo echo -e "$2\n$2\n" | passwd $1
  sudo echo -e "$2\n$2\n" | smbpasswd $1
}

espacio () {
  lsblk
  echo
  df -k $1
# df -h $1
# du -d 1 -h $1
}

dirs () {
  if [ "$1" == "" ];
  then
    base=$(pwd)
  else
    base=$1
  fi
  ls -dAl $base/*/ | more
}

actualizar () {
  sudo apt-get update
  sudo apt-get dist-upgrade
  sudo apt-get upgrade
  sudo apt-get autoremove
}

realias () {
  source /etc/0-bashStandard/.bashrc
}

