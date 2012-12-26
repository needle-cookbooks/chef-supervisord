#
# Cookbook Name:: supervisord
# Recipe:: default
#
# Copyright 2011, Atalanta Systems Ltd
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

if node['supervisord']['install_from_pip']
  include_recipe 'python'
  include_recipe 'runit'

  package 'supervisor' do
    action :remove
  end

  python_pip 'supervisor' do
    version node['supervisord']['version']
    action :install
  end

  runit_service 'supervisord'

else
  package 'supervisor' do
    action :install
  end
end

template "#{node["supervisord"]["conf_dir"]}/supervisord.conf" do
  source "supervisord.conf.erb"
  mode "0644"
  owner "root"
  group "root"
  # Check to make sure each "section" of the config has actual values before we 
  # pass them off to the template; yeah, this is kind of ugly :(
  variables(
    :globals => (node["supervisord"]["globals"].select { |k,v| k unless v.nil? } \
      unless (node["supervisord"]["globals"].map { |k,v| not v.nil? }\
        .select {|a| a}.empty?)),
    :unix_http_server => (node["supervisord"]["unix_http_server"].select { |k,v| k unless v.nil? } \
      unless (node["supervisord"]["unix_http_server"].map { |k,v| not v.nil? }\
        .select {|a| a}.empty?)),
    :inet_http_server => (node["supervisord"]["inet_http_server"].select { |k,v| k unless v.nil? } \
      unless (node["supervisord"]["inet_http_server"].map { |k,v| not v.nil? }\
        .select {|a| a}.empty?)),
    :supervisorctl => (node["supervisord"]["supervisorctl"].select { |k,v| k unless v.nil? } \
      unless (node["supervisord"]["supervisorctl"].map { |k,v| not v.nil? }\
        .select {|a| a}.empty?))
  )
end

if node[:platform] == 'ubuntu'
  template "/etc/default/supervisor" do
    source "ubuntu-supervisor-defaults.sh.erb"
    owner "root"
    group "root"
    mode "0644"
  end

  # replace default init script with our own
  # the default ubuntu one doesn't restart properly
  cookbook_file "/etc/init.d/supervisor" do
    source "ubuntu-supervisor-init.sh"
    owner "root"
    group "root"
    mode "0755"
  end
end

service "supervisor" do
  supports :status => true, :restart => true, :reload => true
  reload_command "supervisorctl update"
  action [:enable, :start]
end

# TODO: starting/restarting the supervisor service may fail if there's an existing:
# "/var/run/supervisor.sock"... you have run:
#
#     unlink /var/run/supervisor.sock
#
# for this to work.
#
# See: http://serverfault.com/questions/114477/supervisor-http-server-port-issue
