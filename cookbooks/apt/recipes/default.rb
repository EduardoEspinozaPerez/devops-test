#
# Cookbook:: apt
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
execute "apt-get update" do
    command "apt-get update"
end

execute "apt-get upgrade -y" do
    command "apt-get upgrade -y"
end