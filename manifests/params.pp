# == Class: dynamic_hosts::params
#
# See README.md for more details.
class dynamic_hosts::params {

  if $::dynamic_hosts_entries {
    $entries = $::dynamic_hosts_entries
  } else {
    $entries = {}
  }

}