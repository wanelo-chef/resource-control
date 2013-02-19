#
# Cookbook Name:: resource-control
# Provider:: project
#
# Copyright 2011, Wanelo, Inc.
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
#

def load_current_resource
  @current_project = Chef::Resource::ResourceControlProject.new(new_resource.name)
  @current_project.load
end

action :create do
  validate!

  create_or_update_project
  set_limits new_resource.project_limits, 'project'
  set_limits new_resource.task_limits, 'task'
  set_limits new_resource.process_limits, 'process'
end

private

def project
  new_resource.name
end

def validate!
  raise ArgumentError.new('name may not include spaces') if new_resource.name.match(/\s/)
  raise ArgumentError.new('comment may not include colons or newlines') if new_resource.comment &&
      new_resource.comment.match(/(:|\n)/)
end

def create_or_update_project
  basecmd = project_exists? ? 'projmod' : 'projadd'
  cmd = Mixlib::ShellOut.new("#{basecmd} -c \"#{new_resource.comment}\" #{project}")
  cmd.run_command
end

def project_exists?
  cmd = Mixlib::ShellOut.new("grep #{project} /etc/project")
  cmd.run_command
  begin
    cmd.error!
    true
  rescue Exception
    false
  end
end

def set_limits(limit_hash, type)
  return unless limit_hash
  limit_hash.each_pair do |limit, values|
    control = "#{type}.#{limit}"

    set_limit(control, values)
  end
end

def set_limit(control, values)
  cmd = Mixlib::ShellOut.new("projmod -a -K \"#{control}=#{values_to_limits(values)}\" #{project}")
  cmd.run_command
  cmd.error!
end

def values_to_limits(values)
  values = Array(values).map { |v| value_to_limit(v) }
  values.join(',')
end

def value_to_limit(value)
  v = %w[privileged]
  if value.is_a?(Hash)
    v << value['value']
    if value['deny']
      v << 'deny'
    elsif value['signal']
      v << "signal=#{value['signal']}"
    else
      v << 'none'
    end
  else
    v << value
    v << 'none'
  end
  "(#{v.join(',')})"
end
