# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu2204"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'lab'
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provision "shell", path: "vm-lab-setup.sh"

end