include_attribute "runas"

default[:webapps][:install_dir] = "#{node[:runas][:dir_path]}/apps"
default[:webapps][:user] = node[:runas][:user]
default[:webapps][:group] = node[:runas][:group]

default[:webapps][:git] = []
