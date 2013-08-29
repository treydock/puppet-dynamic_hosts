# == Class: dynamic_hosts
#
# === Parameters
#
# [*entries*]
#   Hash.  Passed to create_resource to define dynamic_hosts::entry
#   Default: {}
#
# === Examples
#
#  class { 'dynamic_hosts': }
#
#  Defining dynamic_hosts::entry resources
#
#  class { 'dynamic_hosts':
#    entries  => {
#      'example.local'  => { ip_networks => [
#         {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
#         {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
#       },
#     }
#  }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class dynamic_hosts (
  $entries  = $dynamic_hosts::params::entries
) inherits dynamic_hosts::params {

  if $entries and !empty($entries) { create_resources('dynamic_hosts::entry', $entries) }

}
