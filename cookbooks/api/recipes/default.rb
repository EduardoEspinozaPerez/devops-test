#
# Cookbook:: api
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
remote_directory "/opt/user-api" do
    source 'user-api'
    files_owner 'root'                                                                 
    files_group 'root'
    files_mode '0750'
    action :create
    recursive true                                                                    
end