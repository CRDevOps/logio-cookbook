#
# Cookbook Name:: logio
# Provider:: harvest

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

include Chef::Logio::Helpers

use_inline_resources

action :watch do
  stream = @new_resource.stream_name
  log_file = @new_resource.log_file
  if watching? stream, log_file
    Chef::Log.info "Already watching #{@new_resource} - nothing to do."
  else
    converge_by("Watch #{@new_resource}") do
      node.run_state['logio_watched_files'] ||= {}
      node.run_state['logio_watched_files'][stream] ||= []
      node.run_state['logio_watched_files'][stream] << log_file
    end
    Chef::Log.info ":::: #{node.run_state['logio_watched_files']}"
  end
end
