require 'spec_helper_system'

describe 'dynamic_hosts class:' do
  context 'should run successfully' do
    context 'should run successfully' do
      pp = "class { 'dynamic_hosts': }"
  
      context puppet_apply(pp) do
         its(:stderr) { should be_empty }
         its(:exit_code) { should_not == 1 }
         its(:refresh) { should be_nil }
         its(:stderr) { should be_empty }
         its(:exit_code) { should be_zero }
      end
    end
  end

  context 'with entries defined' do
    pp =<<-EOS
class { 'dynamic_hosts':
  entries  => {
    'example.local'  => { ip_networks => [
       {'ip' => '10.0.2.1', 'network' => '10.0.2.0'},
       {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
     },
   }
}
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
    
    describe host('example.local') do
      it { should be_resolvable.by('hosts') }
    end
  end
  
  context 'top-scope variable dynamic_hosts_entries defined' do
    pp =<<-EOS
$dynamic_hosts_entries  = {
  'example-top-scope.local'  => { ip_networks => [
     {'ip' => '10.0.2.2', 'network' => '10.0.2.0'},
     {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
  },
}
class { 'dynamic_hosts': }

    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
    
    describe host('example-top-scope.local') do
      it { should be_resolvable.by('hosts') }
    end
  end
end
