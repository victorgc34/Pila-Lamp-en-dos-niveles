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

#### Arrancar las máquinas:
```bash
vagrant up
# Inicia y configura las máquinas virtuales.
```

#### Detener las máquinas:
```bash
vagrant halt
# Apaga las máquinas sin destruirlas.
```
#### Destruir las máquinas:
```bash
vagrant destroy
# Elimina las máquinas virtuales y todos sus datos.

```

## Provisionamiento

### Script de Provisionamiento: `prov_apache2.sh`


#### Actualización e instalación de paquetes necesarios: 
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 -y
sudo apt install php libapache2-mod-php php-mysql -y
```

#### Desabilita el sitio prederminado de Apache:
```bash
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
```

#### Clona el repositorio y elimina lo innecesario:
```bash
sudo mkdir /var/www/proyecto
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto
sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md
```

#### Mueve los archivos a la carpeta a hostear:
```bash
sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/
```

#### Parametros indispensables:
Estos dos deben de ser identicos con los de prov_mysql
```bash
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe
```

Parametro que hace referencia a la dirección IP de mysql
```bash
IP_MS=192.168.1.3
```

#### Configuración del archivo "config.php":
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

#### Modificacion del permisos y del propietario: 
Con esto añadimos los permisos 755 a todos los archivos dentro de "proyectos" y le cambiamos el usuario a "www-data" para que apache pueda acceder a ellos.
```bash
sudo chmod -R 755 /var/www/proyecto
sudo chown -R www-data:www-data /var/www/proyecto/
```

#### Configuración del sitio de apache:
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

#### Habilita el sitio de apache: 
```bash
sudo a2ensite proyecto.conf
sudo systemctl reload apache2
```

#### Configuración del Firewall para mayor seguridad:
```bash

ufw allow ssh
ufw allow apache
echo "y" | sudo ufw enable
```
### Script de Provisionamiento: `prov_mysql.sh`

#### Actualización de paquetes y instalacion de MySQL:
```bash
sudo apt update
sudo apt upgrade -y
sudo apt install mysql-server -y
```
#### Clonación del repositorio:
```bash
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git $HOME/iaw-practica-lamp
```
####  Importación de script a mysql:
En este, se crea la estructura de la base de datos a utilizar.
```bash
sudo mysql -u root < $HOME/iaw-practica-lamp/db/database.sql
```

#### Parametros para la base de datos:
Los dos primeros deben coincidir con los del "pro_apache2.sh"
```bash
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe
#
IP_MA=192.168.1.2
db_passwd=1234-Admin
```
#### Añadir una contraseña al usuario root de la base de datos:
```bash
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$db_passwd';"
```
#### Creación de un nuevo usuario de MySQL y asignación de privilegios:
```bash
sudo mysql -u root -p$db_passwd -e "CREATE USER '$DB_USER'@'$IP_MA' IDENTIFIED BY '$DB_PASS';"
sudo mysql -u root -p$db_passwd -e "GRANT ALL PRIVILEGES ON lamp_db.* TO '$DB_USER'@'$IP_MA';FLUSH PRIVILEGES;"
```
#### Modificar configuración para que MySQL permita conexiones externas:
```bash
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
```
#### Resolución de problemas:
Para que la base de datos no tarde en responder al quitarle la conexion a internet.
Medida aplicada ya que al impedir la conexión a internet, la base de datos intenta resolver algunos nombres de dominio, lo que causa un retraso importante en la resolucion de peticiones

```bash
sudo echo "skip-name-resolve" >> /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
```
#### Configuración del firewall UFW para SSH y MySQL:
```bash
sudo ufw allow ssh
sudo ufw allow mysql
sudo echo "y" | sudo ufw enable
```

#### Desabilitar todas las conexiones:
Esto impide la conexión a internet
```bash
sudo ufw default deny outgoing
```
### Capturas de pantalla
Esta demuestran que tanto la maqina apache como mysql estan procesando las peticiones:

![Captura desde 2024-11-03 23-53-10](https://github.com/user-attachments/assets/c42e2c54-db0f-44d6-b108-f9b34fd6d41f)

![Captura desde 2024-11-03 23-58-36](https://github.com/user-attachments/assets/a2e009df-6799-4dad-8abf-8fa31f1c5c12)
