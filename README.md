# puppet-dynamic_hosts

[![Build Status](https://travis-ci.org/treydock/puppet-dynamic_hosts.png)](https://travis-ci.org/treydock/puppet-dynamic_hosts)

####Table of Contents

1. [Overview - What is the dynamic_hosts module?](#overview)
2. [Usage - Configuration and customization options](#usage)
    * [Class: dynamic_hosts](#class-dynamic_hosts)
    * [Define: dynamic_hosts::entry](#define-dynamic_hostsentry)
    * [Function: find\_ip\_by_network](#function-find_ip_by_network)
3. [Use Cases - Real world usage scenerios?](#use-cases)
    * [LDAP Automount - Geographically distributed data centers using same LDAP defined Automount](#ldap-automount)
7. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The dynamic_hosts module lets you create dynamic host entries based on a system's IP addresses.

## Usage

### Class: `dynamic_hosts`

By default the class performs no actions.  The `dynamic\_hosts\_entries` top-scope variable can be used to define `dynamic_hosts::entry` resources.

    class { 'dynamic_hosts': }
  
Example of a top-scope `dynamic\_hosts\_entries` variable

    $dynamic_hosts_entries = {
      'example.local' => { 'ip_networks' => [
        {'ip' => '10.0.2.1', 'network' => '10.0.2.0'},
        {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
      }
    }

The class can be defined with the `entries` parameter to also create `dynamic_hosts::entry` resources

    class { 'dynamic_hosts':
      entries  => {
        'example.local'  => { ip_networks => [
           {'ip' => '10.0.2.1', 'network' => '10.0.2.0'},
           {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
         },
       }
    }

#### Parameters for `dynamic_hosts` class

#####`entries`

The Hash that is passed to create_resources to define `dynamic_hosts::entry` resources (defaults to an empty Hash).

The `dynamic_hosts_entries` top-scope variable can be used to define this parameter.  The parameter's value takes presedence over the top-scope variable.

### Defined type: `dynamic_hosts::entry`

Defines a /etc/hosts entry based on the `ip_networks` Hash.  If the system has an IP within the value of the `network` Hash element, then the `ip` value is assigned to the host entry.

The following example creates a /etc/hosts entry for 'example.local' with the 'ip' value from the first hash with a matching 'network' value.

    dynamic_hosts::entry { 'example.local':
      ip_networks => [
        {'ip' => '10.0.2.2', 'network' => '10.0.2.0'},
        {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
      ],
    }

Aliases can also be defined

    dynamic_hosts::entry { 'example.local':
      ip_networks => [
        {'ip' => '10.0.2.2', 'network' => '10.0.2.0'},
        {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
      ],
      host_alises => ['example-foo.local', 'example-bar.local'],
    }

#### Parameters for `dynamic_hosts::entry` defined type

#####`namevar`

The defined type's name that sets the hostname of the /etc/hosts entry.

#####`ip_networks`

Array of Hashes where each Hash has the `ip` of the host entry that's assigned if an interface matches the `network` value.  A Hash with `network` set to `127.0.0.0` can be used as the "catch all".

#####`host_fqdn`

Sets the /etc/hosts entry's FQDN (defaults to `namevar`).

#####`host_aliases`

Array of aliases for the /etc/hosts entry (defaults to undef).

#####`ensure`

Controls the existance of the /etc/hosts entry (defaults to 'present').

### Function: `find\_ip\_by_network`

Returns the IP of the first `network` match found from an Array of Hashes.  Returns false if no match is found.

Each hash must have an `ip` key and a `network` key.

#### Examples for `find\_ip\_by_network` function

In these examples, the puppet client has eth0 with network 10.0.2.0 and lo with 127.0.0.0.

    $ip = find_ip_by_network({'ip' => '10.0.2.2', 'network' => '10.0.2.0'})

Would return: '10.0.2.2'

    $ip = find_ip_by_network({'ip' => '192.168.1.2', 'network' => '192.168.1.0'}, {'ip' => '1.1.1.1', 'network' => '127.0.0.0'})

Would return: '1.1.1.1'

    $ip = find_ip_by_network({'ip' => '192.168.1.2', 'network' => '192.168.1.0'})

Would return: false

- *Type*: rvalue

## Use Cases

### LDAP Automount

*Scenerio:*

A single infrastructure shares LDAP and a NFS server for home directories.  Multiple data centers share these resources in seperate buildings.

All user home directories are automounted based on a single LDAP auto.home entry.  Some of the systems are on a high-speed private network local to the NFS server, while others must use a 'public' network to access the NFS server.

NFS Server IPs:

* eth0: 1.1.1.10 (public LAN) (255.255.255.0)
* eth1: 192.168.2.10 (255.255.255.0)
* lo: 127.0.0.0

Client1 networks:

* eth0: 1.1.1.100 (public LAN) (255.255.255.0)
* eth1: 192.168.2.100 (255.255.255.0)
* lo: 127.0.0.0 (255.255.255.0)

Client2 networks:

* eth0: 1.1.2.100 (public LAN) (255.255.255.0)
* eth1: 10.0.1.10 (255.255.255.0)
* lo: 127.0.0.0


*Solution:*

In LDAP set the hostname for the NFS automount to something like 'automount-nfs-home.local' then use this module to map that hostname to an IP based on the IPs available to each server.

The following would be defined in Puppet (this example is in YAML for readability).

    dynamic_hosts_entries:
      'automount-nfs-home.local':
        ip_networks:
          - ip: '192.168.2.10'
            network: '192.168.2.0'
          - ip: '1.1.1.10'
            network: '127.0.0.0'

In the example above 'Client1' would be assigned this host entry

    192.168.2.10  automount-nfs-home.local

'Client2' would be assigned this host entry

    1.1.1.10 automount-nfs-home.local

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run acceptance tests

    bundle exec rake acceptance
