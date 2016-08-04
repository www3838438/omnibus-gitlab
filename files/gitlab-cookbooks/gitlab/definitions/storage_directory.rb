#
# Copyright:: Copyright (c) 2016 GitLab Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

define :storage_directory, path: nil, owner: 'root', group: nil, mode: nil, recursive: false do
  params[:path] ||= params[:name]
  params[:recursive] = false if File.exist?(params[:path])

  execute "mkdir -p #{params[:path]}" do
    user params[:owner]
    group params[:group] if params[:group]
    not_if { params[:path].nil? }
  end

  execute "chmod #{params[:recursive] ? '-R' : ''} #{params[:mode]} #{params[:path]}" do
    user params[:owner]
    group params[:group] if params[:group]
    not_if { params[:mode].nil? }
  end

  # Ensure directory is in expected state
  directory params[:path] do
    owner params[:owner]
    group params[:group] if params[:group]
    mode params[:mode] if params[:mode]
    recursive params[:recursive]
    only_if { node['gitlab']['manage-storage-directories']['check_expected_state'] }
  end
end
