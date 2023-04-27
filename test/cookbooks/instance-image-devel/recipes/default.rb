# node.default['ganeti']['version'] = '2.16.2'
node.default['ganeti']['yum']['url'] = 'https://ftp2.osuosl.org/pub/ganeti-rpm/$releasever/$basearch'
node.default['ganeti']['master-node'] = 'instance-image.localdomain'
node.default['ganeti']['instance_image']['variants_list'] = %w(default cirros)
node.default['ganeti']['instance_image']['config_defaults']['image_debug'] = 1
node.default['ganeti']['instance_image']['config_defaults']['swap'] = 'no'
node.default['ganeti']['instance_image']['config_defaults']['cache_dir'] = ''
node.default['ganeti']['cluster'].tap do |c|
  c['master-netdev'] = 'eth1'
  c['disk-templates'] = %w(plain)
  c['nic'] = {
    'mode' => 'routed',
    'link' => '100',
  }
  c['extra-opts'] = [
    '--vg-name=ganeti',
    "-H kvm:kernel_path='',initrd_path=''",
  ].join(' ')
  c['name'] = 'ganeti.localdomain'
end

build_essential 'ganeti-instance-image'

package %w(
  automake
  curl
  dump
  kpartx
  lvm2
  parted
  vim
)

execute 'create ganeti volume group' do
  command <<-EOF
  dd if=/dev/zero of=/var/tmp/ganeti_vg bs=1M seek=21480 count=0
  vgcreate ganeti $(losetup --show -f /var/tmp/ganeti_vg)
  EOF
  action :run
  not_if 'vgs ganeti'
end

replace_or_add 'localhost' do
  path '/etc/hosts'
  pattern /^127.0.0.1.*/
  sensitive false
  line '127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4'
end

delete_lines 'remove 127.0.1.1' do
  path '/etc/hosts'
  pattern /^127.0.1.1.*/
  sensitive false
end

append_if_no_line '192.168.10.10' do
  path '/etc/hosts'
  sensitive false
  line '192.168.10.10 ganeti.localdomain'
end

append_if_no_line 'hostname' do
  path '/etc/hosts'
  sensitive false
  line "#{node['network']['interfaces']['eth1']['addresses'].keys[1]} #{node['fqdn']} #{node['hostname']}"
end

include_recipe 'ganeti'
