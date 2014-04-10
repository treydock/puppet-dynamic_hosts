require 'spec_helper'

describe 'dynamic_hosts' do
  let :facts do
    {
      :interfaces => 'lo',
      :network_lo => '127.0.0.0',
    }
  end

  it { should create_class('dynamic_hosts') }

  it { should have_dynamic_hosts__entry_resource_count(0) }

  context 'with entries defined' do
    let :params do
      {
        :entries  => {
          'example.local'  => {
            'ip_networks' => [
              {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
              {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
            ],
          },
        }
      }
    end

    it { should have_dynamic_hosts__entry_resource_count(1) }

    it do
      should contain_dynamic_hosts__entry('example.local').with({
        'ip_networks' => [
            {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
            {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
          ],
      })
    end
  end
  
  context 'with dynamic_hosts_entries top-scope variable defined' do
    let :pre_condition do
      "$dynamic_hosts_entries = {
        'example.local'  => { 'ip_networks' => [
          {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
          {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
        },
      }
      class { 'dynamic_hosts': }"
    end

    it { should have_dynamic_hosts__entry_resource_count(1) }

    it do
      should contain_dynamic_hosts__entry('example.local').with({
        'ip_networks' => [
            {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
            {'ip' => '1.1.1.1', 'network' => '127.0.0.0'},
          ],
      })
    end
  end
end
