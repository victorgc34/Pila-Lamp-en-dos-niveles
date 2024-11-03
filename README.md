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

## Gestión de las Máquinas Virtuales

```bash
# Arrancar las máquinas
vagrant up
# Inicia y configura las máquinas virtuales.

# Detener las máquinas
vagrant halt
# Apaga las máquinas sin destruirlas.

# Destruir las máquinas
vagrant destroy -f
# Elimina las máquinas virtuales y todos sus datos.

```

## Provisionamiento

### Script de Provisionamiento: `prov_apache2.sh`

Este script instala y configura Apache y PHP en la máquina, y clona el proyecto de GitHub. Luego, configura el archivo de configuración de la aplicación PHP para conectar a la base de datos MySQL.

