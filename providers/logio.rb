#
# Cookbook Name:: logio
# Provider:: logio
#
# Copyright (C) 2015 Mauricio Araya V. <hello@mauricioaraya.net>
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

include Chef::Logio::Helpers

use_inline_resources

provides :logio if defined? provides

action :run do
  service_type = @new_resource.service_type
  Chef::Application.fatal!("\"#{service_type}\" is an invalid service") unless valid_service? service_type
  install_nvm
  install_nodejs
  install_logio
  install_pm2
  if service_type.to_sym == :server
    configure_log_server
    configure_web_server
    enable_server
  else # :harvester
    configure_harvester
    enable_harvester
  end
end
