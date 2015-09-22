#
# Cookbook Name:: logio
# Library:: helpers
#
# Author:: Mauricio Araya V. (hello@mauricioaraya.net)
#          http://mauricioaraya.net
#
# Copyright (C) 2015 Mauricio Araya V.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

class Chef
  # Logio module
  module Logio
    # Helpers module
    module Helpers
      def watching?(stream, file)
        node.run_state['logio_watched_files'][stream].include? file
      rescue NoMethodError
        false
      end

      def valid_service?(service_type)
        [:server, :harvester].include?(service_type.to_sym)
      end

      def group_id
        gid = Mixlib::ShellOut.new("eval printf $(id -g -n #{node['logio']['username']})")
        gid.run_command.stdout
      end

      def user_home
        gid = Mixlib::ShellOut.new("eval printf ~#{node['logio']['username']}")
        gid.run_command.stdout
      end

      def reload_users
        ohai 'reload users' do
          plugin 'etc'
          action :reload
        end
      end

      def install_nvm
        nvm_install_dir = "#{user_home}/.nvm"
        remote_file "#{Chef::Config[:file_cache_path]}/nvm-install-#{node['logio']['nvm_version']}.sh" do
          source node['logio']['nvm_installer']
          owner node['logio']['username']
          group group_id
          mode '0700'
          action :create
          retries 2
          retry_delay 1
          not_if { ::File.directory? nvm_install_dir }
        end

        bash 'install-nvm' do
          environment 'HOME' => user_home
          cwd user_home
          code "#{Chef::Config[:file_cache_path]}/nvm-install-#{node['logio']['nvm_version']}.sh"
          user node['logio']['username']
          group group_id
          not_if { ::File.directory? nvm_install_dir }
        end
      end

      def install_nodejs
        nvm_install_dir = "#{user_home}/.nvm"
        bash 'install-node' do
          environment 'HOME' => user_home
          cwd user_home
          code <<-EOH
            source #{nvm_install_dir}/nvm.sh
            nvm install v#{node['logio']['node_version']} &&
            nvm alias default v#{node['logio']['node_version']}
          EOH
          user node['logio']['username']
          group group_id
          not_if { ::File.exist? "#{nvm_install_dir}/alias/default" }
        end
      end

      def install_logio
        nvm_install_dir = "#{user_home}/.nvm"
        bash 'install-logio' do
          environment 'HOME' => user_home
          cwd user_home
          code <<-EOH
            source #{nvm_install_dir}/nvm.sh &&
            npm ls -g log.io ||
            npm install -g log.io
          EOH
          user node['logio']['username']
          group group_id
          retries 2
          retry_delay 1
        end
      end

      def install_pm2
        nvm_install_dir = "#{user_home}/.nvm"
        bash 'install-pm2' do
          environment 'HOME' => user_home
          cwd user_home
          code <<-EOH
            source #{nvm_install_dir}/nvm.sh &&
            npm ls -g pm2 ||
            npm install -g pm2
          EOH
          user node['logio']['username']
          group group_id
          retries 2
          retry_delay 1
        end
      end

      def configure_harvester
        harvester_cfg = {}
        harvester_cfg['nodeName'] = node['logio']['client']['node_name']
        harvester_cfg['logStreams'] = node.run_state['logio_watched_files'].clone if node.run_state.key?('logio_watched_files')
        harvester_cfg['server'] = { host: node['logio']['client']['remote_host'],
                                    port: node['logio']['client']['remote_port']
                                  }
        logio_cfg_path = "#{user_home}/.log.io"
        directory logio_cfg_path do
          owner node['logio']['username']
          group group_id
          recursive true
          action :create
        end

        template "#{logio_cfg_path}/harvester.json" do
          cookbook 'logio'
          source 'json_config.erb'
          variables ({ json_config: JSON.pretty_generate(harvester_cfg) })
          owner node['logio']['username']
          group group_id
        end

        template "#{user_home}/.log.io/harvester.conf" do
          cookbook 'logio'
          source 'load_json_config.erb'
          variables ({
            logio_cfg_path: "#{user_home}/.log.io",
            json_file: 'harvester.json'
          })
          owner node['logio']['username']
          group group_id
        end
      end

      def configure_log_server
        log_server_cfg = {
          host: node['logio']['server']['listen_ip'],
          port: node['logio']['server']['listen_port']
        }

        logio_cfg_path = "#{user_home}/.log.io"
        directory logio_cfg_path do
          owner node['logio']['username']
          group group_id
          recursive true
          action :create
        end

        template "#{logio_cfg_path}/log_server.json" do
          cookbook 'logio'
          source 'json_config.erb'
          variables ({ json_config: JSON.pretty_generate(log_server_cfg) })
          owner node['logio']['username']
          group group_id
        end

        template "#{logio_cfg_path}/log_server.conf" do
          cookbook 'logio'
          source 'load_json_config.erb'
          variables ({
            logio_cfg_path: "#{user_home}/.log.io",
            json_file: 'log_server.json'
          })
          owner node['logio']['username']
          group group_id
        end
      end

      def configure_web_server
        web_server_cfg = {
          host: node['logio']['web_server']['listen_host'],
          port: node['logio']['web_server']['listen_port'],
          restrictSocket: node['logio']['web_server']['restrict_socket']
        }
        web_server_cfg['restrictHTTP'] = node['logio']['web_server']['restrict_http'] unless node['logio']['web_server']['restrict_http'].empty?
        web_server_cfg['auth'] = {} unless node['logio']['web_server']['username'].nil? ||
                                           node['logio']['web_server']['password'].nil?
        web_server_cfg['auth']['user'] = node['logio']['web_server']['username'] unless node['logio']['web_server']['username'].nil?
        web_server_cfg['auth']['pass'] = node['logio']['web_server']['password'] unless node['logio']['web_server']['password'].nil?

        web_server_cfg['ssl'] = {} unless node['logio']['web_server']['ssl_pkey'].nil? ||
                                          node['logio']['web_server']['ssl_cert'].nil?
        web_server_cfg['ssl']['key'] = node['logio']['web_server']['ssl_pkey'] unless node['logio']['web_server']['ssl_pkey'].nil?
        web_server_cfg['ssl']['cert'] = node['logio']['web_server']['ssl_cert'] unless node['logio']['web_server']['ssl_cert'].nil?

        logio_cfg_path = "#{user_home}/.log.io"
        directory logio_cfg_path do
          owner node['logio']['username']
          group group_id
          recursive true
          action :create
        end

        template "#{logio_cfg_path}/web_server.json" do
          cookbook 'logio'
          source 'json_config.erb'
          variables ({ json_config: JSON.pretty_generate(web_server_cfg) })
          owner node['logio']['username']
          group group_id
        end

        template "#{logio_cfg_path}/web_server.conf" do
          cookbook 'logio'
          source 'load_json_config.erb'
          variables ({
            logio_cfg_path: logio_cfg_path,
            json_file: 'web_server.json'
          })
          owner node['logio']['username']
          group group_id
        end
      end

      def enable_server
        template '/etc/init.d/logio-server.sh' do
          cookbook 'logio'
          source "#{node['platform_family']}_service.erb"
          variables ({ app_name: 'log.io-server',
                       app_script: 'logio-server.sh',
                       user: node['logio']['username'],
                       nvm_loader: "#{user_home}/.nvm/nvm.sh"
                    })
          owner 'root'
          group 'root'
          mode '0755'
        end

        service 'logio-server.sh' do
          supports start: true
          action [:enable, :start]
          notifies :start, 'service[logio-server.sh]'
        end
      end

      def enable_harvester
        template '/etc/init.d/logio-harvester.sh' do
          cookbook 'logio'
          source "#{node['platform_family']}_service.erb"
          variables ({ app_name: 'log.io-harvester',
                       app_script: 'logio-harvester.sh',
                       user: node['logio']['username'],
                       nvm_loader: "#{user_home}/.nvm/nvm.sh"
                    })
          owner 'root'
          group 'root'
          mode '0755'
        end

        service 'logio-harvester.sh' do
          supports start: true
          action [:enable, :start]
          notifies :start, 'service[logio-harvester.sh]'
        end
      end
    end
  end
end
