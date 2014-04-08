module Puppet::Parser::Functions
  newfunction(:find_ip_by_network, :type => :rvalue, :doc => <<-EOS
Returns the IP of the associated network found on the client.

This function must be provided an Array of Hashes.  Each Hash
must contain the keys 'ip' and 'network'.

The first Hash with a 'network' that matches the client's available networks
will have its 'ip' value returned.
    EOS
  ) do |args|

    # Validate the number of args
    if args.size != 1
      raise(Puppet::ParseError, "find_ip_by_network(): Takes exactly one " +
            "args, but #{args.size} given.")
    end

    ip_networks = args[0]

    # Validate the argument.
    if not ip_networks.is_a?(Array)
      raise(TypeError, "find_ip_by_network(): The argument must be an " +
            "Array, but a #{ip_networks.class} was given.")
    end

    # Validate the argument elements type.
    if not ip_networks.all? { |h| h.is_a?(Hash) }
      raise(TypeError, "find_ip_by_network(): The argument elements must be a Hash.")
    end
    
    # Validate the argument elements contents.
    if not ip_networks.all? { |h| h.has_key?('network') and h.has_key?('ip') }
      raise(TypeError, "find_ip_by_network(): The argument elements must have a network and an ip key.")
    end

    Puppet::Parser::Functions.autoloader.load(:has_ip_network) \
      unless Puppet::Parser::Functions.autoloader.loaded?(:has_ip_network)

    result = false
    ip_networks.each do |ip_network|
      if function_has_ip_network([ip_network['network']])
        result = ip_network['ip']
        break
      end
    end

    result
  end
end
