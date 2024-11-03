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

## Explicación del Script de Provisión para Apache (`prov_apache2.sh`)

```bash
# Actualización e Instalación de Paquetes
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 -y
sudo apt install php libapache2-mod-php php-mysql -y

# Configuración de Apache
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# Clonación de la Aplicación
sudo mkdir /var/www/proyecto
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /var/www/proyecto
sudo rm -R /var/www/proyecto/db /var/www/proyecto/README.md

# Configuración de la Aplicación
sudo cp /var/www/proyecto/src/* /var/www/proyecto/ && rm -R /var/www/proyecto/src/
sudo tee /var/www/proyecto/config.php > /dev/null <<EOF
# Configuración de la conexión a la base de datos en `config.php`

# Permisos y Propietario
sudo chmod -R 755 /var/www/proyecto
sudo chown -R www-data:www-data /var/www/proyecto/

# Configuración de Apache para el Proyecto
sudo tee /etc/apache2/sites-available/proyecto.conf > /dev/null <<EOF
sudo a2ensite proyecto.conf
sudo systemctl reload apache2

# Configuración del Firewall
ufw allow ssh
ufw allow apache
echo "y" | sudo ufw enable
