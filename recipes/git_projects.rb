
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

  git "#{app_dir}" do
    repository "#{data[:git_url]}"
    user "#{node[:webapps][:user]}"
    group "#{node[:webapps][:group]}"
    action :sync
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

end
