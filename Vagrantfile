Vagrant.configure("2") do |config|
  # Configuración del SO de la maquina virtual de Vagrant
  config.vm.box = "ubuntu/jammy64"
  
  # Configuración de recursos de las maquinas de VirtualBox
  config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048      # Asigna 2 GB de RAM a la VM
      vb.cpus = 2           # Asigna 2 CPU a la VM
  end
  
  # Definición de la máquina virtual Apache
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "VictorGarcApache"
    apache.vm.network "public_network"
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.network "private_network", ip: "192.168.1.2", virtualbox__intnet: "redproyecto"
    apache.vm.provision "shell", path: "prov_apache2.sh"
  end

  # Definición de la máquina virtual MySQL
  config.vm.define "mysql" do |mysql|
    mysql.vm.hostname = "VictorGarciaMysql"
    mysql.vm.network "public_network"
    mysql.vm.network "private_network", ip: "192.168.1.3", virtualbox__intnet: "redproyecto"
    mysql.vm.provision "shell", path: "prov_mysql.sh"
  end
end
