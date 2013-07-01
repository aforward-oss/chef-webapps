
directory "#{node[:webapps][:install_dir]}" do
  owner "#{node[:webapps][:user]}"
  group "#{node[:webapps][:group]}"
end

include_recipe "webapps::git_projects"
