#
# Cookbook Name:: logio
# Attributes:: default
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

default['logio']['nvm_version'] = '0.26.1'
default['logio']['node_version'] = '0.12.7'
default['logio']['nvm_installer'] = "https://raw.githubusercontent.com/creationix/nvm/v#{node['logio']['nvm_version']}/install.sh"
default['logio']['username'] = 'logio'

# Service setup
default['logio']['server']['listen_ip'] = '0.0.0.0'
default['logio']['server']['listen_port'] = 28_777
default['logio']['client']['remote_host'] = 'localhost'
default['logio']['client']['remote_port'] = 28_777
default['logio']['client']['node_name'] = 'localhost'

default['logio']['web_server']['listen_host'] = '0.0.0.0'
default['logio']['web_server']['listen_port'] = 28_778
default['logio']['web_server']['username'] = nil
default['logio']['web_server']['password'] = nil
default['logio']['web_server']['ssl_pkey'] = nil
default['logio']['web_server']['ssl_cert'] = nil
default['logio']['web_server']['restrict_socket'] = '*:*'
default['logio']['web_server']['restrict_http'] = []
