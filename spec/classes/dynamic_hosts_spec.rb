require 'spec_helper'

describe 'dynamic_hosts' do
  include_context :defaults

  let :facts do
    default_facts
  end

  it { should create_class('dynamic_hosts') }
  it { should contain_class('dynamic_hosts::params') }


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
    let :facts do
      default_facts.merge({
        :dynamic_hosts_entries => {
          'example.local'  => { 'ip_networks' => [
            {'ip' => '10.0.0.1', 'network' => '10.0.0.0'},
            {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
          },
        }
      })
    end
    
    let :params do
      {}
    end
    
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
