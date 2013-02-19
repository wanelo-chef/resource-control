#
# Cookbook Name:: resource-control
# Resource:: project
#
# Copyright 2012, Wanelo, Inc.
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
actions :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :comment, :kind_of => [String, NilClass], :default => nil

attribute :project_limits, :kind_of => [Hash, NilClass], :default => nil
attribute :task_limits, :kind_of => [Hash, NilClass], :default => nil
attribute :process_limits, :kind_of => [Hash, NilClass], :default => nil

def initialize(*args)
  super(*args)
  @action = :create
end

def load
  cmd = Mixlib::ShellOut.new("projects -l #{self.name}")
  cmd.run_command
  begin
    cmd.error!

    project = cmd.stdout
    self.comment = project.match(/comment: "([^"]+)"/)[1] rescue nil
    attrs = project.match(/attribs:/)[1] rescue nil
  rescue Exception
    false
  end
end
