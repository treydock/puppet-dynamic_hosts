# == Class: dynamic_hosts
#
# See README.md for more details.
class dynamic_hosts ($entries  = $dynamic_hosts::params::entries) inherits dynamic_hosts::params {

  if empty($entries) {
    $_entries = $::dynamic_hosts_entries
  } else {
    $_entries = $entries
  }

  if $_entries {
    validate_hash($_entries)

    if !empty($_entries) { create_resources('dynamic_hosts::entry', $_entries) }
  }

}
