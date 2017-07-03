# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.require_version '>= 1.7.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  %w(
    centos-6.9
    centos-7.3
    debian-8.8
    debian-9.0
    ubuntu-12.04
    ubuntu-14.04
    ubuntu-16.04
  ).each do |os|
    config.vm.define os do |node|
      node.vm.hostname = 'instance-image.localdomain'
      node.vm.box = "bento/#{os}"
      node.vm.network :private_network, ip: '192.168.10.11'
      node.vm.provision :chef_solo do |chef|
        chef.version = '12.18.31'
        chef.cookbooks_path = 'cookbooks'
        chef.run_list = %w(
          recipe[apt]
          recipe[instance-image-devel]
          recipe[instance-image-devel::install]
          recipe[instance-image-devel::variants]
          recipe[instance-image-devel::instance_add]
        )
      end
    end
  end
end
