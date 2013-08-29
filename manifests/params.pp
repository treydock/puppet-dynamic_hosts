# == Class: dynamic_hosts::params
#
# The dynamic_hosts configuration settings.
#
# === Variables
#
# [*dynamic_hosts_entries*]
#   Hash. Contains the Hashes passed to create_resources
#   to define dynamic_host::entry resources.
#   Default: {}
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class dynamic_hosts::params {

  $entries = $::dynamic_hosts_entries ? {
    undef   => false,
    default => $::dynamic_hosts_entries,
  }

}