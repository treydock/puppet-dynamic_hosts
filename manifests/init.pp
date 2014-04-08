# == Class: dynamic_hosts
#
# See README.md for more details.
class dynamic_hosts (
  $entries  = $dynamic_hosts::params::entries
) inherits dynamic_hosts::params {

  if $entries {
    validate_hash($entries)

    if !empty($entries) { create_resources('dynamic_hosts::entry', $entries) }
  }

}
