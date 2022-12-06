#!/bin/bash

# USO:
#  BakConfigs /path/a/los/respaldos/en/otro/disco/

# REQUERIMIENTOS PREVIOS:
#  sudo apt-get install git-all
#  sudo apt install rsync

# Manualmente la primera vez, desde el :
#  cd $1
#  git config --global --add safe.directory $(pwd)
#  git init
#  git config --global user.email "ALGO@example.com"
#  git config --global user.name "NOMBRE_USUARIO"
#  Para que no pida credenciales siempre, agregar al archivo ~/.gitconfig:
#    [credential]
#    helper = store
#  git remote add origin https://github.com/NOMBRE_USUARIO/Configs_$(hostname).git

########################################################################
# El programa principal se estructura como función
# para poder ponerlo de primero por legibilidad
function principal {

   # Agregar el nombre de este equipo para que quede en directorio propio en Git
   # Comenzar el log de este respaldo:
   DirBaksLocal=$1/$(hostname)

   # Crear el directorio para respaldo (no importa si ya está creado)
   mkdir -p $DirBaksLocal

#  # Sincronizar lo que haya, si se usa el mismo repo para varios:
#  GITpull $DirBaksLocal

   # Iniciar el log de este respaldo
   echo -e "\n" >> $DirBaksLocal/BakConfig_$(date +"%Y-%m").log
   echo "Respaldos del " $(date +"%d, %H:%M") >> $DirBaksLocal/BakConfig_$(date +"%Y-%m").log

   # Respaldar los crontab de todos los usuarios:
   BakCrons $DirBaksLocal

   # RESPALDAR CONFIGURACIONES PERSONALIZADAS DE ESTE EQUIPO
   # Directorios a respaldar:
   echo "#### DIRECORIOS A RESPALDAR ####"
   #  grep y no cat, para ignorar lineas vacias, que respaldarian /
   grep '[^[:space:]]' ${0}.DIRS | while read Linea
      do
      BakDir "$Linea" "$DirBaksLocal"
   done

   # Archivos a respaldar:
   echo "#### ARCHIVOS A RESPALDAR ####"
   #  grep y no cat, para ignorar lineas vacias, que respaldarian /
   grep '[^[:space:]]' ${0}.ARCH | while read Linea
      do
      BakArch $Linea $DirBaksLocal
   done

   # Hacer accesibles todos los archivos respaldados (requiere ser root):
   chown -R nobody $DirBaksLocal &&
   chgrp nogroup -R $DirBaksLocal &&
   chmod 555 -R $DirBaksLocal
   chmod 777 -R $DirBaksLocal

   # Sincronizar con GitHub
   GITpush $DirBaksLocal
}

########################################################################
function BakCrons {
   ### RESPALDAR LOS CRON DE TODOS LOS USUARIOS ###

   # Crear el directorio para respaldo (no importa si ya está creado)
   mkdir -p $1/crons
   # Listar el crontab de cada usuario (esto solo puede hacerlo root)
   for user in $(cut -f1 -d: /etc/passwd)
      do crontab -u $user -l > $1/crons/crontab_$user 2>/dev/null
   done
   # Eliminar los archivos vacios (usuarios sin crontab)
   find $1/crons/ -size 0 -delete
}

########################################################################
function BakDir {
   ### DUPLICAR EL DIRECTORIO $1 A LA MISMA UBICACION DENTRO DEL DIRECTORIO $2 ###

   # Si el directorio a respaldar no existe en este equipo, no crear el respaldo
   if [[ ! -d $1 ]] ; then return ; fi

   # Crear el directorio para respaldo (no importa si ya está creado)
      mkdir -p  $2/$1
   #      +-- Recurse into directories
   #      |  +-- Preserve modification times
   #      |  |  +-- Copiar los archivos y no solo symlinks
   #      |  |  |  +-- No pararse en errores
   #      |  |  |  |
   echo 'rsync -r -t -L --ignore-errors --chmod=777 '$1 $(dirname $2$1) '>> '$2/BakConfig_$(date +"%Y-%m").log
         rsync -r -t -L --ignore-errors --chmod=777  $1 $(dirname $2$1)  >>  $2/BakConfig_$(date +"%Y-%m").log
}

########################################################################
function BakArch {
   ### COPIAR EL ARCHIVO $1 A LA MISMA UBICACION DENTRO DEL DIRECTORIO $2 ###
   # Crear el directorio para el archivo respaldo (no importa si ya está creado)
   mkdir -p $(dirname $2$1)
echo 'cp '$1 $2$1
      cp  $1 $2$1
}


########################################################################
function GITpull {
   # Sincronizar de github:
   cd $1
   git pull --allow-unrelated-histories
}

########################################################################
function GITpush {
   # Sincronizar a github:
   cd $1
   git add .
   git commit -m $(hostname)_$(date +"%Y-%m-%d_%H:%M")
   git branch -M main
   git push -u origin main
   # La primera vez ejecutar manualmente el push
   # para que pida y registre el usuario y clave/token
}

########################################################################
# El programa principal se llama al final cuando las funciones están definidas
# "$@" es para que reciba los parámetros que se hayan pasado al script
principal "$@"; exit

