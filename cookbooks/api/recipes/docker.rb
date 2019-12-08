execute "Docker build" do
    command "cd /opt/user-api/ && docker build -t user-api ."
end

execute "Docker run" do
    connection_string= "jdbc:postgresql://20.0.0.11:5432/api?connectTimeout=10&socketTimeout=10" 
    command "cd /opt/user-api/ && docker run -dit -p '8069:8069' -e 'SPRING_DATASOURCE_URL=#{connection_string}' --restart always user-api"
end