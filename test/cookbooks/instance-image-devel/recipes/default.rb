include_recipe 'build-essential'

%w(
  automake
  curl
  dump
  kpartx
  parted
  vim).each do |p|
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

hostsfile_entry '192.168.125.10' do
  hostname 'ganeti.local'
  action :create
end

hostsfile_entry node['network']['interfaces']['eth0']['addresses'].keys[1] do
  hostname node['fqdn']
  aliases [node['hostname']]
  unique true
  action :create
end
