#
# Cookbook:: api
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package 'openjdk-11-jdk' do
    action :install
end

remote_directory "/opt/user-api" do
    source 'user-api'
    files_owner 'root'                                                                 
    files_group 'root'
    files_mode '0750'
    action :create
    recursive true                                                                    
end

execute "Build user-api" do
    command "cd /opt/user-api/ && ./gradlew build"
end

execute "Docker build" do
    command "cd /opt/user-api/ && docker build -t user-api ."
end

execute "Docker run" do
    command "cd /opt/user-api/ && docker run -dit -p '8069:8069' --restart always user-api"
end