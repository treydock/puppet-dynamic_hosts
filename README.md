# puppet-dynamic_hosts

[![Build Status](https://travis-ci.org/treydock/puppet-dynamic_hosts.png)](https://travis-ci.org/treydock/puppet-dynamic_hosts)

####Table of Contents

1. [Overview - What is the dynamic_hosts module?](#overview)
2. [Use Cases - Real world usage scenerios?](#use-cases)
    * [LDAP Automount - Geographically distributed data centers using same LDAP defined Automount](#ldap-automount)
3. [Usage - Configuration and customization options](#usage)
    * [Class: dynamic_hosts](#class-dynamic_hosts)
    * [Define: dynamic_hosts::entry](#define-dynamic_hostsentry)
    * [Function: find\_ip\_by_network](#function-find_ip_by_network)
7. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The dynamic_hosts module lets you create dynamic host entries based on a system's IP addresses.

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

## Usage

### Class: dynamic_hosts

By default the class performs no actions.  The **dynamic\_hosts\_entries** top-scope variable can be used to define **dynamic_hosts::entry** resources.

    class { 'dynamic_hosts': }
  
Example of a top-scope **dynamic\_hosts\_entries** variable

    $dynamic_hosts_entries = {
      'example.local' => { 'ip_networks' => [
        {'ip' => '10.0.2.1', 'network' => '10.0.2.0'},
        {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
      }
    }

The class can be defined with the **entries** parameter to also create **dynamic_hosts::entry** resources

    class { 'dynamic_hosts':
      entries  => {
        'example.local'  => { ip_networks => [
           {'ip' => '10.0.2.1', 'network' => '10.0.2.0'},
           {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
         },
       }
    }


### Define: dynamic_hosts::entry

Creates a /etc/hosts entry for 'example.local' with the 'ip' value from the first hash with a matching 'network' value.

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
  
### Function: find\_ip\_by_network

Returns the IP of the first 'network' match found from an Array of Hashes.  Returns false if no match is found.

Each hash must have an 'ip' key and a 'network' key.

*Examples:*

In these examples, the puppet client has eth0 with network 10.0.2.0 and lo with 127.0.0.0.

    $ip = find_ip_by_network({'ip' => '10.0.2.2', 'network' => '10.0.2.0'})

Would return: '10.0.2.2'

    $ip = find_ip_by_network({'ip' => '192.168.1.2', 'network' => '192.168.1.0'}, {'ip' => '1.1.1.1', 'network' => '127.0.0.0'})

Would return: '1.1.1.1'

    $ip = find_ip_by_network({'ip' => '192.168.1.2', 'network' => '192.168.1.0'})

Would return: false

- *Type*: rvalue

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system
