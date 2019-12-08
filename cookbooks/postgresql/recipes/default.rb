postgresql_server_install 'PostgreSQL Server install' do
    action :install
end

postgresql_server_install 'PostgreSQL Server configuration' do
    password 'a1b2c3d4e5'
    initdb_locale 'en_US.UTF-8'
    action :create
end

postgresql_access 'PostgreSQL Server local access configuration' do
    comment 'Local postgres access'
    access_type 'local'
    access_db 'all'
    access_user 'postgres'
    access_addr nil
    access_method 'ident'
end

postgresql_access 'PostgreSQL Server remote access configuration' do
    comment 'Remote postgres access'
    access_type 'host'
    access_db 'all'
    access_user 'all'
    access_addr '20.0.0.10/24'
    access_method 'md5'
end

execute 'API database create' do
    command 'sudo -u postgres psql -c "create database api;"'
end