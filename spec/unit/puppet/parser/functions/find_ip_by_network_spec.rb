require 'spec_helper'

describe Puppet::Parser::Functions.function(:find_ip_by_network) do

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  subject do
    function_name = Puppet::Parser::Functions.function(:find_ip_by_network)
    scope.method(function_name)
  end

  it 'should exist' do
    Puppet::Parser::Functions.function('find_ip_by_network').should == "function_find_ip_by_network"
  end

  context "On Linux Systems" do
    before :each do
      scope.stubs(:lookupvar).with('interfaces').returns('eth0,lo')
      scope.stubs(:lookupvar).with('network').returns(:undefined)
      scope.stubs(:lookupvar).with('network_eth0').returns('10.0.2.0')
      scope.stubs(:lookupvar).with('network_lo').returns('127.0.0.0')
    end

    it 'should return match for primary network (10.0.2.0)' do
      subject.call([[{'ip' => '10.0.2.2', 'network' => '10.0.2.0'},{'ip' => '1.1.1.1', 'network' => '127.0.0.0'}]]).should == '10.0.2.2'
    end

    it 'should return match for loopback network (127.0.0.1)' do
      subject.call([[{'ip' => '1.1.1.1', 'network' => '127.0.0.0'}]]).should == '1.1.1.1'
    end
    
    it 'should return false if no matches' do
      subject.call([[{'ip' => '1.1.1.1', 'network' => '0.0.0.0'}]]).should be false
    end
    
    it 'should raise a ParseError if there is less than 1 argument' do
      expect { subject.call([]).to raise_error(Puppet::ParseError, /Takes exactly one arguments/) }
    end
    
    it 'should raise a ParseError if there is more than 1 argument' do
      expect { subject.call([[],[]]).to raise_error(Puppet::ParseError, /Takes exactly one arguments/) }
    end
    
    it 'should raise a TypeError if the argument is not an Array' do
      expect { subject.call([{}]).to raise_error(TypeError, /The argument must be an Array/) }
    end
    
    it 'should raise a TypeError if the argument elements are not Hashes' do
      expect { subject.call([["foo", "bar"]]).to raise_error(TypeError, /elements must be a Hash/) }
    end
    
    it 'should raise a TypeError if the argument Hashes do not have proper keys' do
      expect { subject.call([[{'foo' => 'bar'}]]).to raise_error(TypeError, /elements must have a network and an ip key/) }
    end
  end
end
