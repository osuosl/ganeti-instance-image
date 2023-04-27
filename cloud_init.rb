#!/usr/bin/env ruby

# Copyright (C) 2015 Oregon State University
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

require 'yaml'

def cloud_init
  host = ENV['INSTANCE_NAME'] || ''
  user = ENV['CINIT_USER']
  ssh_key = ENV['CINIT_SSH_KEY']
  disable_root = ENV['CINIT_DISABLE_ROOT'] == 'yes' ? 1 : 0
  ssh_pwauth = ENV['CINIT_SSH_PWAUTH'] == 'yes' ? 1 : 0
  manage_resolv_conf = ENV['CINIT_MANAGE_RESOLV_CONF'] == 'yes' ? true : false
  name_servers = ENV['DNS_SERVERS']
  search_domains = ENV['DNS_SEARCH']
  domain = host.split('.').drop(1).join('.')
  resolv_conf = nil

  if manage_resolv_conf
    manage_conf = true
    resolv_conf = {
      'nameservers' => name_servers.split,
      'searchdomains' => search_domains.split,
      'domain' => domain,
      'options' => {
        'rotate' => true,
        'timeout' => 1
      }
    }
  else
    manage_conf = false
  end

  init_modules =
    %w(
      migrator
      bootcmd
      write-files
      growpart
      resizefs
      set_hostname
      update_hostname
      update_etc_hosts
      resolv_conf
      rsyslog
      users-groups
      ssh
    )

  config = {
    'hostname' => host.sub(/\..*$/, ''),
    'fqdn' => host,
    'instance-id' => host,
    'disable_root' => disable_root,
    'ssh_pwauth' => ssh_pwauth,
    'manage-resolv-conf' => manage_conf,
    'manage_resolv_conf' => manage_conf,
    'cloud_init_modules' => init_modules,
    'users' => [
      'name' => user,
      'primary-group' => user,
      'groups' => %w(wheel adm systemd-journal),
      'sudo' => ['ALL=(ALL) NOPASSWD:ALL'],
      'shell' => '/bin/bash',
      'lock_passwd' => true,
      'ssh-authorized-keys' => [ssh_key]
    ],
    'groups' => [user],
    'resolv_conf' => resolv_conf
  }

  config.to_yaml
end

puts cloud_init
