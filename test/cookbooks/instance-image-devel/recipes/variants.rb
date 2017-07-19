instance_image_variant 'cirros' do
  image_name 'cirros-0.3.5'
  image_type 'qcow2'
  image_verify 'no'
  image_cleanup 'no'
  nomount 'yes'
  image_url 'http://ftp.osuosl.org/pub/osl/ganeti-images/'
end
