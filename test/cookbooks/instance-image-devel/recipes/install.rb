execute 'install instance-image' do
  cwd '/vagrant'
  command <<-EOF
  ./autogen.sh
  ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc \
      --with-os-dir=/srv/ganeti/os
  make
  make install
  EOF
  action :run
end

include_recipe 'ganeti::instance_image'

delete_resource(:yum_repository, 'ganeti-instance-image')
delete_resource(:apt_repository, 'ganeti-instance-image')
delete_resource(:package, 'ganeti-instance-image')
