# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'instance-image'
  if Vagrant.has_plugin?('vagrant-omnibus')
    config.omnibus.chef_version = 'latest'
  end
  if Vagrant.has_plugin?('vagrant-berkshelf')
    config.berkshelf.enabled = true
  end
  config.vm.box = 'chef/centos-6.6'
  config.vm.network :private_network, type: 'dhcp'
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      ganeti: {
        :"master-node" => true,
        cluster: {
          :"master-netdev" => 'lo',
          :"extra-opts" => '--vg-name ganeti',
          nic: {
            mode: 'routed',
            link: '100'
          },
          name: 'ganeti.local'
        }
      }
    }
    chef.run_list = [
      'recipe[instance-image-devel]',
      'recipe[ganeti::_test]',
      'recipe[ganeti]'
    ]
  end
end