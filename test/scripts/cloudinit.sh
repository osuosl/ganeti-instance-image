export INSTANCE_NAME=foo.bar.example.org
export CINIT_USER=foobar
export CINIT_MANAGE_RESOLV_CONF="yes"
export DNS_SERVERS="192.168.1.1 192.168.1.2"
export DNS_SEARCH="example.org example.bak"
export CINIT_DISABLE_ROOT="yes"
export CINIT_SSH_PWAUTH="no"
./cloud_init.rb
