# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'ebpf-lab'
    vb.memory = 8192
    vb.cpus = 4
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.synced_folder "./lab", "/home/vagrant/lab"

  # Provision script runs automatically only when the machine gets created
  # If you need to run it again, run vagrant up --provision
  config.vm.provision "shell", path: "prepare-vm.sh"

end
