name 'docker'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '4.10.0'

source_url 'https://github.com/chef-cookbooks/docker'
issues_url 'https://github.com/chef-cookbooks/docker/issues'

supports 'amazon'
supports 'centos'
supports 'scientific'
supports 'oracle'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

chef_version '>= 12.15'
gem 'docker-api', '~> 1.34.0'
