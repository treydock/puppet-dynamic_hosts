# puppet-dynamic_hosts [![Build Status](https://travis-ci.org/treydock/puppet-dynamic_hosts.png)](https://travis-ci.org/treydock/puppet-dynamic_hosts)

Puppet module to create dynamic host entries based on a system's local IP addresses.

## Reference

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

### Dependencies

* rake
* bundler

### Unit testing

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

### Vagrant system tests

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system