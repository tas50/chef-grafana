require 'spec_helper'

describe 'grafana::default' do

  before do
    stub_command 'which nginx'
    Chef::Config[:config_file] = '/dev/null'
  end

  context 'with default attributes' do

    let(:chef_run) do
      ChefSpec::Runner.new.converge described_recipe
    end

    it 'creates base directory for grafana' do
      expect(chef_run).to create_directory('/srv/apps/grafana').with(
        mode: '0755',
        owner: chef_run.node['nginx']['user']
      )
    end

    it 'loads grafana::_nginx recipe' do
      expect(chef_run).to include_recipe 'grafana::_nginx'
    end

    it 'loads grafana::_install_file recipe' do
      expect(chef_run).to include_recipe 'grafana::_install_file'
    end

    it 'generate grafana config file with use set to nginx user' do
      config_path = "#{chef_run.node['grafana']['web_dir']}/config.js"
      expect(chef_run).to create_template(config_path).with(
        mode: '0644',
        user: chef_run.node['nginx']['user']
      )
    end

  end

  context 'with no webserver' do

    let(:chef_run) do
      ChefSpec::Runner.new do |runner|
        runner.node.set['grafana']['webserver'] = ''
      end.converge described_recipe
    end

    it 'creates base directory for grafana' do
      expect(chef_run).to create_directory('/srv/apps/grafana').with(
        mode: '0755',
        owner: 'nobody'
      )
    end

    it 'do not load grafana::nginx recipe' do
      expect(chef_run).not_to include_recipe 'grafana::_nginx'
    end

    it 'loads grafana::_install_file recipe' do
      expect(chef_run).to include_recipe 'grafana::_install_file'
    end

    it 'generate grafana config file with user set to nobody' do
      config_path = "#{chef_run.node['grafana']['web_dir']}/config.js"
      expect(chef_run).to create_template(config_path).with(
        mode: '0644',
        user: 'nobody'
      )
    end

  end

end
