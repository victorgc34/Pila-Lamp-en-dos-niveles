#!/bin/bash
# Actualización de la lista de paquetes
sudo apt update

# Actualización de paquetes instalados
sudo apt upgrade -y

# Instalación del servidor Apache
sudo apt install apache2 -y

# Deshabilita el sitio predeterminado de Apache
sudo a2dissite 000-default.conf 

# Instalación de PHP y módulos necesarios para MySQL
sudo apt install php libapache2-mod-php php-mysql -y

# Reinicia Apache para cargar las configuraciones nuevas
sudo systemctl restart apache2

# Crea el directorio para el proyecto en Apache
sudo mkdir /var/www/proyecto

# Clona el repositorio del proyecto base desde GitHub
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto

# Elimina directorios y archivos innecesarios del proyecto clonado
sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md

# Mueve los archivos de la carpeta src al directorio raíz del proyecto y elimina src
sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/

##########################################
#Configuración de config.php del proyecto#
##########################################

# Parámetros de configuración para la base de datos
######################
#Parametros database#
######################
# Parámetros de conexión a la base de datos
IP_MS=192.168.1.3
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe

# Creación del archivo de configuración config.php con los parámetros definidos
sudo tee /var/www/proyecto/config.php > /dev/null <<EOF
<?php

define('DB_HOST', '$IP_MS');
define('DB_NAME', 'lamp_db');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');

\$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

?>
EOF

# Cambia los permisos del directorio del proyecto
sudo chmod -R 755 /var/www/proyecto

# Cambia el propietario del directorio del proyecto a www-data
sudo chown -R www-data:www-data /var/www/proyecto/

##################################
#Configuración de sitio de Apache#
##################################

sudo tee /etc/apache2/sites-available/proyecto.conf > /dev/null <<EOF
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/proyecto
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Habilita el nuevo sitio de Apache y recarga el servicio
sudo a2ensite proyecto.conf
sudo systemctl reload apache2

###################################
#Configuración de firewall con UFW#
###################################

# Permitir conexiones SSH
ufw allow ssh

# Permitir tráfico HTTP para Apache
ufw allow apache

# Habilita el firewall UFW
echo "y" | sudo ufw enable
