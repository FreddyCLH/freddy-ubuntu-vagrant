# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

private_ip = "192.168.99.10"
secondary_disk = "secondary_disk.vdi"
secondary_disk_size = 50 * 1024
number_of_monitors = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :freddy_linux do |freddy_linux_config|
    freddy_linux_config.vm.box = "ubuntu/bionic64"
    freddy_linux_config.vm.host_name = 'freddy-linux'
    freddy_linux_config.vm.network "private_network", ip: private_ip
    freddy_linux_config.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
      v.gui = true
      v.customize ["setextradata", :id, "GUI/Seamless","1"]
	  # Two screens
	  v.customize ["modifyvm", :id, "--vram", "32"]
	  v.customize ["modifyvm", :id, "--monitorcount", number_of_monitors]


      # Secondary Disk
      unless File.exist?(secondary_disk)
        v.customize ['createhd', '--filename', secondary_disk, '--format', 'VDI', '--size', secondary_disk_size]
      end
        v.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', secondary_disk]
    end

    freddy_linux_config.vm.synced_folder "provision/", "/provision"

    config.vm.provision "shell", path: "provision/provision.bash"
    
  end

end
