
Este proyecto configura un entorno de desarrollo con dos máquinas virtuales (VM) utilizando Vagrant. Una VM sirve como servidor Apache para hospedar aplicaciones web en PHP, mientras que la otra es un servidor MySQL para gestionar la base de datos. Este entorno se configura y se provisiona automáticamente mediante scripts de shell.

## Requisitos previos

- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/)

## Estructura del proyecto

- **Vagrantfile**: Configura las dos máquinas virtuales y sus redes.
- **prov_apache2.sh**: Provisiona la máquina Apache (instala y configura Apache, PHP, y una aplicación PHP).
- **prov_mysql.sh**: Provisiona la máquina MySQL (instala MySQL y configura una base de datos para la aplicación).

## Configuración de las Máquinas Virtuales

El `Vagrantfile` define dos máquinas:

- **Apache VM**
  - Nombre de host: `VictorGarcApache`
  - Red pública y privada (IP privada: `192.168.1.2`)
  - Puerto de Apache (80) mapeado al host (8080)
  - Provisión mediante `prov_apache2.sh`
  
- **MySQL VM**
  - Nombre de host: `VictorGarciaMysql`
  - Red pública y privada (IP privada: `192.168.1.3`)
  - Provisión mediante `prov_mysql.sh`

## Provisionamiento

### Script de Provisionamiento: `prov_apache2.sh`

Este script instala y configura Apache y PHP en la máquina, y clona el proyecto de GitHub. Luego, configura el archivo de configuración de la aplicación PHP para conectar a la base de datos MySQL.

#### Comandos explicados:

```bash
sudo apt update && sudo apt upgrade -y

Actualiza la lista de paquetes e instala las actualizaciones pendientes del sistema.

bash

sudo apt install apache2 -y

Instala Apache2, el servidor web.

bash

sudo a2dissite 000-default.conf

Desactiva la configuración del sitio predeterminado de Apache.

bash

sudo apt install php libapache2-mod-php php-mysql -y

Instala PHP, el módulo de PHP para Apache, y la extensión de PHP para MySQL.

bash

sudo systemctl restart apache2

Reinicia Apache para cargar los nuevos módulos.

bash

sudo mkdir /var/www/proyecto

Crea el directorio del proyecto en el servidor web.

bash

sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto

Clona el repositorio del proyecto en el directorio del servidor web.

bash

sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md

Elimina carpetas y archivos innecesarios del proyecto clonado.

bash

sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/

Copia los archivos de src al directorio principal del proyecto y elimina la carpeta src.

bash

sudo tee /var/www/proyecto/config.php > /dev/null <<EOF

Genera el archivo config.php con las credenciales y configuración para la base de datos, reemplazando DB_HOST, DB_USER, y DB_PASSWORD.

bash

sudo chmod -R 755 /var/www/proyecto
sudo chown -R www-data:www-data /var/www/proyecto/

Establece permisos y propietario para los archivos del proyecto.

bash

sudo tee /etc/apache2/sites-available/proyecto.conf > /dev/null <<EOF

Crea un nuevo archivo de configuración de sitio de Apache para el proyecto.

bash

sudo a2ensite proyecto.conf
sudo systemctl reload apache2

Habilita el sitio del proyecto y recarga la configuración de Apache.

bash

ufw allow ssh
ufw allow apache
echo "y" | sudo ufw enable

Configura el firewall para permitir SSH y tráfico de Apache.
Script de Provisionamiento: prov_mysql.sh

Este script instala MySQL y configura la base de datos y las credenciales de usuario necesarias para la aplicación PHP.
Comandos explicados:

bash

sudo apt update && sudo apt upgrade -y

Actualiza la lista de paquetes e instala actualizaciones pendientes.

bash

sudo apt install mysql-server -y

Instala el servidor MySQL.

bash

sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git $HOME/iaw-practica-lamp
sudo mysql -u root < $HOME/iaw-practica-lamp/db/database.sql

Clona el repositorio del proyecto y carga la base de datos inicial.

bash

sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$db_passwd';"

Configura una nueva contraseña para el usuario root en MySQL.

bash

sudo mysql -u root -p$db_passwd -e "CREATE USER '$DB_USER'@'$IP_MA' IDENTIFIED BY '$DB_PASS';"
sudo mysql -u root -p$db_passwd -e "GRANT ALL PRIVILEGES ON lamp_db.* TO '$DB_USER'@'$IP_MA'; FLUSH PRIVILEGES;"

Crea un usuario en MySQL para la aplicación y le concede privilegios sobre la base de datos.

bash

sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

Modifica la configuración para permitir conexiones remotas.

bash

sudo echo "skip-name-resolve" >> /etc/mysql/mysql.conf.d/mysqld.cnf

Configura MySQL para omitir la resolución de nombres, lo cual acelera las conexiones cuando no hay Internet.

bash

sudo ufw allow ssh
sudo ufw allow mysql
echo "y" | sudo ufw enable
sudo ufw default deny outgoing

Configura el firewall para permitir SSH y MySQL, y deniega el tráfico saliente por defecto.
