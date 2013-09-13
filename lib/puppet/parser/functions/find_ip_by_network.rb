module Puppet::Parser::Functions
  function('has_ip_network')

  newfunction(:find_ip_by_network, :type => :rvalue, :doc => <<-EOS
  
    EOS
  ) do |arguments|
    
    # Validate the number of arguments
    if arguments.size != 1
      raise(Puppet::ParseError, "find_ip_by_network(): Takes exactly one " +
            "arguments, but #{arguments.size} given.")
    end

    ip_networks = arguments[0]

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

    Puppet::Parser::Functions.function('has_ip_network')

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
