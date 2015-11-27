# == Define: dynamic_hosts::entry
#
# See README.md for more details.
define dynamic_hosts::entry (
  $ip_networks,
  $host_fqdn      = 'UNSET',
  $host_aliases   = 'UNSET',
  $ensure         = 'present'
) {

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
      ensure       => $ensure,
      name         => $host_fqdn_real,
      host_aliases => $host_aliases_real,
      ip           => $ip,
    }
  }

}
