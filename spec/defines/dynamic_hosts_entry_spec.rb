require 'spec_helper'

describe 'dynamic_hosts::entry' do
  include_context :defaults

  let :facts do
    default_facts
  end

  let(:title) { 'example.local' }

  let :default_params do
    {
      :ip_networks => [
        {'ip' => '192.168.1.1', 'network' => '192.168.1.0'},
        {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
        {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
      ],
    }
  end

  let :params do
    default_params
  end

  context 'with IP matching ip_networks catch-call' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,lo',
        :network_eth0 => '192.168.2.0',
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '1.1.1.1',
      })
    end
  end

  context 'with IP matching first ip_networks' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,lo',
        :network_eth0 => '192.168.1.0',
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '192.168.1.1',
      })
    end
  end

  context 'with IP matching second ip_networks' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,lo',
        :network_eth0 => '10.0.0.0',
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '10.0.0.1',
      })
    end
  end
  
  context 'with network_eth1 => 192.168.1.0 and multiple matching networks' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,eth1,lo',
        :network_eth0 => '10.0.0.0',
        :network_eth1 => '192.168.1.0',
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '192.168.1.1',
      })
    end
  end
  
  context 'with network_eth0 => 192.168.1.0 and multiple matching networks' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,eth1,lo',
        :network_eth0 => '192.168.1.0',
        :network_eth1 => '10.0.0.0',
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '192.168.1.1',
      })
    end
    
    context 'with first match in ip_networks being 10.0.0.0' do
      let :params do
        {
          :ip_networks => [
            {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
            {'ip' => '192.168.1.1', 'network' => '192.168.1.0'},
            {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
          ],
        }
      end
      
      it do
        should contain_host('dynamic_hosts::entry example.local').with({
          'ensure'        => 'present',
          'name'          => 'example.local',
          'host_aliases'  => nil,
          'ip'            => '10.0.0.1',
        })
      end
    end
  end
  
  context 'with only ip_networks catch-all' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,eth1,lo',
        :network_eth0 => '192.168.1.0',
        :network_eth1 => '10.0.0.0',
      })
    end
    
    let :params do
      {
        :ip_networks => [
          {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
        ],
      }
    end
    
    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => nil,
        'ip'            => '1.1.1.1',
      })
    end
  end

  context 'with host_aliases defined' do
    let :params do
      default_params.merge({
        :host_aliases => ['example-foo.local', 'example-bar.local'],
      })
    end

    it do
      should contain_host('dynamic_hosts::entry example.local').with({
        'ensure'        => 'present',
        'name'          => 'example.local',
        'host_aliases'  => ['example-foo.local', 'example-bar.local'],
        'ip'            => '1.1.1.1',
      })
    end
  end

  context 'with no matches' do
    let :facts do
      default_facts.merge({
        :interfaces => 'eth0,lo',
        :network_eth0 => '192.168.1.0',
      })
    end
    
    let :params do
      { :ip_networks => [{'ip' => '10.0.0.1', 'network' => '10.0.0.0'}] }
    end
    
    it { should_not contain_host('dynamic_hosts::entry example.local') }
  end
  
  context 'with ensure => absent' do
    let(:params) {{ :ip_networks => [{'ip' => '1.1.1.1', 'network' => '127.0.0.0'}], :ensure => 'absent' }}
    it { should contain_host('dynamic_hosts::entry example.local').with_ensure('absent') }
  end
  
  context 'with invalid value for ip_networks' do
    let(:params) {{ :ip_networks => "foo" }}
    it { expect { should contain_host('dynamic_hosts::entry example.local') }.to raise_error(Puppet::Error, /is not an Array/) }
  end
  
  context 'with invalid value for ensure' do
    let(:params) {{ :ip_networks => [], :ensure => "foo" }}
    it { expect { should contain_host('dynamic_hosts::entry example.local') }.to raise_error(Puppet::Error, /does not match/) }
  end
end
