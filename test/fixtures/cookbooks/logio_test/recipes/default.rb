#
# Cookbook Name:: logio_test
# Recipe:: default

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

include_recipe 'apt' if node['platform_family'] == 'debian'

include_recipe 'build-essential::default'

logio_harvest 'auth' do
  stream_name 'auth'
  log_file '/var/log/auth.log'
end

user node['logio']['username'] do
  comment node['logio']['username'].capitalize
  shell '/bin/bash'
  home "/home/#{node['logio']['username']}"
  manage_home true
end

group 'adm' do
  action :modify
  members node['logio']['username']
  append true
end

logio 'server'
logio 'harvester'
