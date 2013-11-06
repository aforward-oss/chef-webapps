
# EXAMPLE GIT PROJECTS
# "git_projects": {
#   "name": "replay",
#   "git_url": "deployer@git.10xdevelopers.com:replay.git",
#   "files": {
#     "lib/replay/environments/prod.exs" => [
#       "config :dynamo,",
#       "  compile_on_demand: false,",
#       "  reload_modules: false",
#       "config :server,",
#       "  port: 8888,",
#       "  acceptors: 100,",
#       "  max_connections: 10000"
#     ]
#   }
# }



node[:webapps][:git_projects].each do |data|
  app_dir = "#{node[:webapps][:install_dir]}/#{data[:name]}"

  ["pids","logs"].each do |d|
    directory "#{node[:webapps][:install_dir]}/#{d}" do
      recursive true
      owner "#{node[:webapps][:user]}"
      group "#{node[:webapps][:group]}"
    end
  end

  execute "cleanup_owner" do
    cwd "#{app_dir}"
    command "chown -R #{node[:webapps][:user]}:#{node[:webapps][:group]} ."
    only_if { File.exists?( app_dir ) }
  end  

  git "#{app_dir}" do
    repository "#{data[:git_url]}"
    user "#{node[:webapps][:user]}"
    group "#{node[:webapps][:group]}"
    depth 1
  end

  data[:files].each do |filename,contents|

    directory File.dirname("#{app_dir}/#{filename}") do
      recursive true
      owner "#{node[:webapps][:user]}"
      group "#{node[:webapps][:group]}"
    end

    file "#{app_dir}/#{filename}" do
      owner "#{node[:webapps][:user]}"
      group "#{node[:webapps][:group]}"
      mode "0644"
      action :create
      content "#{contents.join("\n")}"
    end
  end

  if data[:monit]
    template "#{node[:monit][:confd_dir]}/#{data[:name]}.conf" do
      source "monit_process.conf.erb"
      owner "root"
      group "root"
      mode 0700
      variables( :name => data[:name], :pidfile => "#{node[:webapps][:install_dir]}/pids/#{data[:name]}.pid", :start => "#{app_dir}/bin/up", :stop => "#{app_dir}/bin/down" )
      notifies :reload, resources(:service => "monit"), :delayed
      action :create
    end
  end


end
