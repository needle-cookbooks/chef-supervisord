action :supervise do
  template "#{node['supervisord']['conf_dir']}/conf.d/#{new_resource.name}.conf" do
    source new_resource.template
    cookbook new_resource.cookbook
    owner "root"
    group "root"
    mode "0644"
    variables :program => new_resource

    notifies :restart, resources(:service => "supervisor")
  end
end
