require 'spec_helper_acceptance'

describe 'dynamic_hosts::entry define:' do
  context 'with only ip_networks defined' do
    it 'should run successfully' do
      pp =<<-EOS
      dynamic_hosts::entry { 'entry.local':
        ip_networks => [
          {'ip' => '10.0.2.3', 'network' => '10.0.2.0'},
          {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
        ],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe host('entry.local') do
      it { should be_resolvable.by('hosts') }
    end
  end

  context 'with ip_networks and host_aliases defined' do
    it 'should run successfully' do
      pp =<<-EOS
      dynamic_hosts::entry { 'entry.local':
        ip_networks => [
          {'ip' => '10.0.2.3', 'network' => '10.0.2.0'},
          {'ip' => '1.1.1.1', 'network' => '127.0.0.0'}
        ],
        host_aliases => ['entry-foo.local', 'entry-bar.local'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    ['entry.local', 'entry-foo.local', 'entry-bar.local']. each do |hostname|
      describe host(hostname) do
        it { should be_resolvable.by('hosts') }
      end
    end
  end
end
