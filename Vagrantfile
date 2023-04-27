# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.require_version '>= 1.7.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  %w(
    almalinux-8
    almalinux-9
    centos-7
    debian-10
    debian-11
    ubuntu-18.04
    ubuntu-20.04
    ubuntu-22.04
  ).each do |os|
    config.vm.define os do |node|
      node.vm.hostname = 'instance-image.localdomain'
      node.vm.box = "bento/#{os}"
      node.vm.network :private_network, ip: '192.168.10.11'
      node.vm.provider 'virtualbox' do |v|
        v.memory = 2048
        v.cpus = 2
      end
      node.vm.provision :chef_solo do |chef|
        chef.version = '17'
        chef.install = true
        chef.cookbooks_path = 'cookbooks'
        chef.binary_env = 'CHEF_LICENSE=accept-no-persist'
        chef.run_list = %w(
          recipe[instance-image-devel]
          recipe[instance-image-devel::install]
          recipe[instance-image-devel::variants]
          recipe[instance-image-devel::instance_add]
        )
      end
    end
  end
end
