# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.7.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'instance-image'
  config.omnibus.chef_version = 'latest' if
    Vagrant.has_plugin?('vagrant-omnibus')
  config.berkshelf.enabled = true if
    Vagrant.has_plugin?('vagrant-berkshelf')
  config.vm.box = 'chef/centos-6.6'
  config.vm.network :private_network, type: 'dhcp'
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :"ganeti" => {
        :"master-node" => true,
        :"cluster" => {
          :"master-netdev" => 'lo',
          :"extra-opts" => '--vg-name ganeti -H kvm:kernel_path=""',
          :"disk-templates" => %w(plain),
          :"nic" => {
            :"mode" => 'routed',
            :"link" => '100'
          },
          :"name" => 'ganeti.local'
        }
      }
    }
    chef.run_list = %w(
      recipe[instance-image-devel]
      recipe[ganeti]
      recipe[instance-image-devel::install]
      recipe[instance-image-devel::variants]
    )
  end
end
