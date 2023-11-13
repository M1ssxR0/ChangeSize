#!/bin/bash

# COLORES

redColour="\e[0;31m\033[1m"
grayColour="\e[0;37m\033[1m"
greenColour="\e[0;32m\033[1m"

# Bienvenida

tput civis #Oculta el cursor, por estética

echo -e "\nBienvenida al examen de DNS :p"
sleep 2

# Funcion para el ctrl+c (no tengo mucha paciencia)
# Muestra en pantalla que está saliendo y fuerza un codigo de error de 1 porque es na salida forzada

function ctrl_c(){
	echo -e "\n ${redColour} [!] Saliendo... ${endColour} \n"
	tput cnorm && exit 1 #El tput cnorm para que nos vuelva a mostrar el cursor
}

trap ctrl_c INT


# Variables globales

## Archivo netplan
netplan_file="/etc/netplan/00-installer-config.yaml"

# 1. Actualización del sistema e instalación del servicio

echo -e "\n Actualizando el sistema..."
apt update -y &>/dev/null # Redirijo la salida estandar al /dev/null

if [ $? -eq 0 ]; then
	echo -e "\n ${greenColour}[+]${endColour}${grayColour}Actualización completada ${endColour}"
else
	echo -e "\n ${redColour}[-]${endColour}${grayColour}Actualización fallida :( ${endColour}"
fi

sleep 2

echo -e "\n Instalando paquetes..."
apt install bind9 bind9utils -y &>/dev/null

if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+]${endColour} ${grayColour}Servicio instalado :) ${endColour}"
else
	echo -e "\n${redColour}[-]${endColour} ${grayColour}Servicio no instalado ${endColour}"
fi

sleep 2

# 2. Ahora cambiamos el ~/.bashrc

# Función para pedir el input del usuario y almacenarlo en $user_stdin

echo -e "\nVamos con la configuración del bashrc \n"

echo 'export PS1="\e[01;31m Rocío del Pilar \e[01;35m \D{%A %e %B %G %R} \e[00;31m \n\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]"' >> /home/usuario/.bashrc

source /home/usuario/.bashrc

if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+]${endColour}${GrayColour}Documento del usuario cambiado${endColour}"
else
	echo -e "\n${redColour}[-]${endColour}${GrayColour}No se ha podido modificar el archivo${endColour}"
fi

sleep 2

echo 'export PS1="\e[01;31m Rocío del Pilar root \e[01;35m \D{%A %e %B %G %R} \e[00;31m \n\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]"' >> /root/.bashrc

source /root/.bashrc

if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+]${endColour}${GrayColour}Documento del admin cambiado ${endColour}"
else
	echo -e "\n${redColour}[-]${endColour}${GrayColour}No se ha podido modificar el archivo${endColour}"
fi

# Función para manejar el input del usuario almacenándolo en la variable user_stdi
get_user_stdin() {
	read -p "$1: " user_stdin
	echo "$user_stdin"
}

# Configuración de IP

echo -e "Ahora configuraré tu IP como estática... (de nada)"
ip_address=$(get_user_stdin "Dirección IP")
cidr=$(get_user_stdin "Máscara de red (CIDR)")
dns1_server=$(get_user_stdin "Servidor DNS primario")
dns2_server=$(get_user_stdin "Servidor DNS secundario")
gateway=$(get_user_stdin "Puerta de enlace")
hostname=$(get_user_stdin "Nombre del servidor DNS")

# Aplicar la configuración

echo "network:
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - $ip_address$cidr
      routes:
        - to: default
          via: $gateway
      nameservers:
        addresses:
          - $dns1_server
          - $dns2_server
        search:
          - $hostname
  version: 2" > "$netplan_file"

# Aplicamos cambios...
sudo netplan apply

# Si el código de salida del comando es 0, exitoso, si no, indica que algo salió mal
if [ $? -eq 0 ]; then
	echo -e " \n${greenColour}[+]${endColour} ${grayColour} Configuración realizada con éxito!! ${endColour}"
else
	echo -e "\n${redColour}[!]${endColour} ${grayColour} Algo salió mal... ${endColour}\n"
fi

# Por último, modificamos la fuente a una más grande

echo "Haciendo los últimos cambios en la fuente..."

sed -i -e 's\"8x16"\"16x32"\g' -e 's/"Fixed"/"Terminus"/7g' /etc/default/console-setup
update-initramfs -u &>/dev/null

echo -e "\n${greenColour}[+]${endColour} ${grayColour}Configuración terminada${endColour}"
tput cnorm
