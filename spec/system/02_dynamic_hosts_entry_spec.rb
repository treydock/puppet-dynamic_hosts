require 'spec_helper_system'

describe 'dynamic_hosts::entry define:' do
  context 'should run successfully' do
    pp =<<-EOS
dynamic_hosts::entry { 'entry.local':
  ip_networks => [
    {'ip' => '10.0.2.3', 'network' => '10.0.2.0'},
    {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
  ],
}
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
    
    describe host('entry.local') do
      it { should be_resolvable.by('hosts') }
    end
  end

  context 'should create host aliases' do
    pp =<<-EOS
dynamic_hosts::entry { 'entry.local':
  ip_networks => [
    {'ip' => '10.0.2.3', 'network' => '10.0.2.0'},
    {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
  ],
  host_aliases => ['entry-foo.local', 'entry-bar.local'],
}
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
    
    ['entry.local', 'entry-foo.local', 'entry-bar.local']. each do |hostname|
      describe host(hostname) do
        it { should be_resolvable.by('hosts') }
      end
    end
  end
end
