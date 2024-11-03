# Pila LAMP en dos niveles

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

## Gestión de las Máquinas Virtuales

#### Arrancar las máquinas
```bash
vagrant up
# Inicia y configura las máquinas virtuales.
```

#### Detener las máquinas
```bash
vagrant halt
# Apaga las máquinas sin destruirlas.
```
#### Destruir las máquinas
```bash
vagrant destroy
# Elimina las máquinas virtuales y todos sus datos.

```

## Provisionamiento

### Script de Provisionamiento: `prov_apache2.sh`


#### Actualización e instalación de paquetes necesarios 
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 -y
sudo apt install php libapache2-mod-php php-mysql -y
```
#### Desabilita el sitio prederminado de Apache
```bash
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
```
#### Clona el repositorio y elimina lo innecesario
```bash
sudo mkdir /var/www/proyecto
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto
sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md
```
#### Mueve los archivos a la carpeta a hostear
```bash
sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/
```
#### Parametros indispensables
Estos dos deben de ser identicos con los de prov_mysql
```bash
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe
```
Parametro que hace referencia a la dirección IP de mysql
```bash
IP_MS=192.168.1.3
```

#### Configuración del archivo "config.php" 
Este archivo se utiliza para que la conexión que la base de datos sea posible.
```bash
sudo tee /var/www/proyecto/config.php > /dev/null <<EOF
<?php

define('DB_HOST', '$IP_MS');
define('DB_NAME', 'lamp_db');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');

\$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

?>
EOF

```

#### Modificacion del permisos y del propietario 
Con esto añadimos los permisos 755 a todos los archivos dentro de "proyectos" y le cambiamos el usuario a "www-data" para que apache pueda acceder a ellos.
```bash
sudo chmod -R 755 /var/www/proyecto
sudo chown -R www-data:www-data /var/www/proyecto/
```
#### Configuración del sitio de apache
Esta comando lo que hace es añadir el archivo de configuración de sitio y indicarle que la ruta de donde tiene los recursos a hostear es "/var/www/proyecto".
```bash
sudo tee /etc/apache2/sites-available/proyecto.conf > /dev/null <<EOF
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/proyecto
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
```

#### Habilita el sitio de apache 
```bash
sudo a2ensite proyecto.conf
sudo systemctl reload apache2
```

##### Configuración del Firewall para mayor seguridad
```bash
ufw allow ssh
ufw allow apache
echo "y" | sudo ufw enable
```
