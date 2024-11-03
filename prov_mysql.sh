#Configuración de mysql
sudo apt update
sudo apt upgrade -y
sudo apt install mysql-server -y
sudo git clone https://github.com/josejuansanchez/iaw-practica-lamp.git $HOME/iaw-practica-lamp
sudo mysql -u root < $HOME/iaw-practica-lamp/db/database.sql
######################
#Parametros database:#
######################
#####!!!!!!Importante¡¡¡¡¡¡¡¡¡
#$IP_MA=ip_maquina_apache
#$db_passwd=contraseña_usuario_root_database
#Estos dos parametros deben coincidir con los del prov_apache2.sh
DB_USER=vgarciac
DB_PASS=C3r8L2E9kcUe
##
IP_MA=192.168.1.2
db_passwd=1234-Admin
#######################
#######################
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$db_passwd';"
sudo mysql -u root -p$db_passwd -e "CREATE USER '$DB_USER'@'$IP_MA' IDENTIFIED BY '$DB_PASS';"
sudo mysql -u root -p$db_passwd -e "GRANT ALL PRIVILEGES ON lamp_db.* TO '$DB_USER'@'$IP_MA';FLUSH PRIVILEGES;"
##MOdificar configuracion para que mysql permita conexiones desde fuera
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
################
#Para que la base de datos no tarde en responder al quitarle la conexion a internet
sudo echo "skip-name-resolve" >> /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
sudo ufw allow ssh
sudo ufw allow mysql
sudo echo "y" | sudo ufw enable
sudo ufw default deny outgoing


