require 'spec_helper_acceptance'

describe 'dynamic_hosts class:' do
  context 'default parameters' do
    it 'should run successfully' do
      pp = "class { 'dynamic_hosts': }"

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  context 'with entries defined' do
    it 'should run successfully' do
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

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe host('example.local') do
      it { should be_resolvable.by('hosts') }
    end
  end

  context 'top-scope variable dynamic_hosts_entries defined' do
    it 'should run successfully' do
      pp =<<-EOS
      $dynamic_hosts_entries  = {
        'example-top-scope.local'  => { ip_networks => [
           {'ip' => '10.0.2.2', 'network' => '10.0.2.0'},
           {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}],
        },
      }
      class { 'dynamic_hosts': }

      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe host('example-top-scope.local') do
      it { should be_resolvable.by('hosts') }
    end
  end
end
