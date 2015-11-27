#
class dynamic_hosts::params {

  $entries = hiera_hash('dynamic_hosts_entries', {})

}
