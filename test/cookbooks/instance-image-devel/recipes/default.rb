include_recipe 'build-essential'

%w(
  automake
  dump
  kpartx
  parted).each do |p|
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
