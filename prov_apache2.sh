#/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install apache2 -y
sudo a2dissite 000-default.conf 
sudo apt install php libapache2-mod-php php-mysql -y
sudo systemctl restart apache2
sudo mkdir /var/www/proyecto
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto
sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md
sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/

##########################################
#Configuración de config.php del proyecto#
##########################################

######################
#Parametros database#
######################
#####!!!!!!Importante¡¡¡¡¡¡¡¡¡
#$IP_MS=ip_maquina_mysql
#$db_passwd=contraseña_usuario_root_database
IP_MS=192.168.1.3
#Estos dos parametros deben coincidir con los del prov_mysql.sh
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe

sudo tee /var/www/proyecto/config.php > /dev/null <<EOF
<?php

define('DB_HOST', '$IP_MS');
define('DB_NAME', 'lamp_db');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');

\$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

?>
EOF


##########################################

sudo chmod -R 755 /var/www/proyecto
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
###################################

sudo a2ensite proyecto.conf
sudo systemctl reload apache2

###################################
ufw allow ssh
ufw allow apache
echo "y" | sudo ufw enable

