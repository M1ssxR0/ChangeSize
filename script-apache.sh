#!/bin/bash

# COLORES

redColour="\e[0;31m\033[0.5m"
grayColour="\e[0;37m\033[0.5m"
greenColour="\e[0;32m\033[0.5m"
endColour="\033[0m\e[0m"

# Bienvenida

tput civis #Oculta el cursor, por estética

echo -e "\n${greenColour}Bienvenida al examen :p${endColour}"
sleep 1

# Funcion para el ctrl+c (no tengo mucha paciencia)
# Muestra en pantalla que está saliendo y fuerza un codigo de error de 1 porque es na salida forzada

function ctrl_c(){
	echo -e "\n\n ${redColour} [!] Saliendo... ${endColour} \n"
	tput cnorm && exit 1 #El tput cnorm para que nos vuelva a mostrar el cursor
}

trap ctrl_c INT


# Variables globales

## Archivo netplan
netplan_file="/etc/netplan/00-installer-config.yaml"

# 1. Instalando el servicio

tput cnorm

echo -ne "\n${grayColour}Introduce el servicio que deseas instalar: ${endColour}" && read service
apt install $service -y &>/dev/null

tput civis

# Comprobamos que el comando se ha desarrollado sin ningún problema (código de eroror = 0)
if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+]${endColour} ${grayColour}Servicio instalado :) ${endColour}"
else
	echo -e "\n${redColour}[-]${endColour} ${grayColour}Servicio no instalado D: ${endColour}"
fi

sleep 2

# 2. Ahora cambiamos el ~/.bashrc

# Función para pedir el input del usuario y almacenarlo en $user_stdin

echo -e "\nVamos con la configuración del bashrc...\n"
sleep 1

echo 'export PS1="\e[01;31m Rocío :p \e[01;35m \D{%A %e %B %G %R} \e[00;31m \n\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]"' >> /home/usuario/.bashrc

source /home/usuario/.bashrc

if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+] ${endColour}${GrayColour}Documento del usuario cambiado${endColour}"
else
	echo -e "\n${redColour}[-] ${endColour}${GrayColour}No se ha podido modificar el archivo${endColour}"
fi

sleep 2

echo 'export PS1="\e[01;31m Rocío :p - Root \e[01;35m \D{%A %e %B %G %R} \e[00;31m \n\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\]"' >> /root/.bashrc

source /root/.bashrc

if [ $? -eq 0 ]; then
	echo -e "\n${greenColour}[+]${endColour}${GrayColour} Documento del admin cambiado \n${endColour}"
else
	echo -e "\n${redColour}[-]${endColour}${GrayColour} No se ha podido modificar el archivo${endColour}"
fi

# Función para manejar el input del usuario almacenándolo en la variable user_stdi
get_user_stdin() {
	read -p "$1: " user_stdin
	echo "$user_stdin"
}

# Configuración de IP

echo -e "Ahora configuraré tu IP como estática... (de nada)\n"

tput cnorm
ip_address=$(get_user_stdin "Dirección IP")
cidr=$(get_user_stdin "Máscara de red (CIDR)")
dns1_server=$(get_user_stdin "Servidor DNS primario")
dns2_server=$(get_user_stdin "Servidor DNS secundario")
gateway=$(get_user_stdin "Puerta de enlace")
tput civis

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
  version: 2" > "$netplan_file"

# Aplicamos cambios...
sudo netplan apply

# Si el código de salida del comando es 0, exitoso, si no, indica que algo salió mal
if [ $? -eq 0 ]; then
	echo -e " \n${greenColour}[+]${endColour} ${grayColour} Configuración realizada con éxito!! ${endColour}"
else
	echo -e "\n${redColour}[!]${endColour} ${grayColour} Algo salió mal... ${endColour}\n"
fi

echo -e "\n${greenColour}[+]${endColour} ${grayColour}Configuración terminada! A trabajar :D\n\n${endColour}"
tput cnorm
