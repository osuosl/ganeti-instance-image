netdev =
  case node['platform_family']
  when 'rhel'
    if node['platform_version'].to_i < 7
      'eth1'
    else
      'enp0s8'
    end
  when 'debian'
    case node['platform']
    when 'debian'
      if node['platform_version'].to_i < 9
        'eth1'
      else
        'enp0s8'
      end
    when 'ubuntu'
      if node['platform_version'].to_i < 16
        'eth1'
      else
        'enp0s8'
      end
    end
  end
node.default['yum']['base']['baseurl'] = 'http://centos.osuosl.org/$releasever/os/$basearch'
node.default['yum']['updates']['baseurl'] = 'http://centos.osuosl.org/$releasever/updates/$basearch/'
node.default['yum']['extras']['baseurl'] = 'http://centos.osuosl.org/$releasever/extras/$basearch/'
node.default['yum']['epel']['baseurl'] = "http://epel.osuosl.org/#{node['platform_version'].to_i}/$basearch"
node.default['ganeti']['master-node'] = 'instance-image.localdomain'
node.default['ganeti']['instance_image']['variants_list'] = %w(default cirros)
node.default['ganeti']['instance_image']['config_defaults']['image_debug'] = 1
node.default['ganeti']['instance_image']['config_defaults']['swap'] = 'no'
node.default['ganeti']['instance_image']['config_defaults']['cache_dir'] = ''
node.default['ganeti']['cluster'].tap do |c|
  c['master-netdev'] = netdev
  c['disk-templates'] = %w(plain)
  c['nic'] = {
    'mode' => 'routed',
    'link' => '100'
  }
  c['extra-opts'] = [
    '--vg-name=ganeti',
    "-H kvm:kernel_path='',initrd_path=''"
  ].join(' ')
  c['name'] = 'ganeti.localdomain'
end

include_recipe 'yum-centos' if platform_family?('rhel')
include_recipe 'build-essential'

%w(
  automake
  curl
  dump
  kpartx
  parted
  vim
).each do |p|
  package p
end

execute 'create ganeti volume group' do
  command <<-EOF
  dd if=/dev/zero of=/var/tmp/ganeti_vg bs=1M seek=21480 count=0
  vgcreate ganeti $(losetup --show -f /var/tmp/ganeti_vg)
  EOF
  action :run
  not_if 'vgs ganeti'
end

hostsfile_entry '127.0.0.1' do
  hostname 'localhost'
  aliases %w(localhost.localdomain localhost4 localhost4.localdomain4)
  action :create
end

hostsfile_entry '192.168.10.10' do
  hostname 'ganeti.localdomain'
  action :create
end

hostsfile_entry node['network']['interfaces'][netdev]['addresses'].keys[1] do
  hostname node['fqdn']
  aliases [node['hostname']]
  unique true
  action :create
end

include_recipe 'ganeti'
