# == Define: dynamic_hosts::entry
#
# Defines a /etc/hosts entry based on the ip_networks Hash.
# If the system has an IP within the "network" then the "ip" value
# is assigned to the host entry.
#
# === Parameters
#
# [*namevar*]
#   String.  Sets the hostname of the hosts entry.
#
# [*ip_networks*]
#   Array of Hashes.
#   Each Hash has the 'ip' of the host entry that's assigned if an interface matches the 'network' value.
#   A Hash with 'network' set to '127.0.0.0' can be used as the "catch all".
#
# [*host_fqdn*]
#   String. Sets the host entry's FQDN value.
#   Default: $namevar
#
# [*host_aliases*]
#   Array. List of aliases for the host entry.
#   Default: undef
#
# [*ensure*]
#   String.  Controls the existence of the host entry.
#   Valid values are present and absent
#   Default: present
#
# === Examples
#
#  dynamic_hosts::entry { 'foo.local':
#    ip_networks  => [
#      {'ip' => '192.168.1.1', 'network' => '192.168.1.0'},
#      {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
#      {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
#    ],
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
define dynamic_hosts::entry (
  $ip_networks,
  $host_fqdn      = 'UNSET',
  $host_aliases   = 'UNSET',
  $ensure         = 'present'
) {

  include dynamic_hosts::params

  validate_array($ip_networks)
  validate_re($ensure, '^(present|absent)$')

  $host_fqdn_real = $host_fqdn ? {
    'UNSET' => $name,
    default => $host_fqdn,
  }

  $host_aliases_real = $host_aliases ? {
    'UNSET' => undef,
    default => $host_aliases,
  }

  $ip = find_ip_by_network($ip_networks)

  if $ip {
    host { "dynamic_hosts::entry ${name}":
      ensure        => $ensure,
      name          => $host_fqdn_real,
      host_aliases  => $host_aliases_real,
      ip            => $ip,
    }
  }

}
