namespace :environment do
  task :common do
    set :name, 'mysql'
    set :image, 'mysql'
    host 'dockhost02.yzguy.io'
  end

  desc 'Production environment'
  task :production => :common do
    set_current_environment(:production)
    env_vars MYSQL_ROOT_PASSWORD: 'password'
    host_port 3306, container_port: 3306
    host_volume '/opt/mysql_data', container_volume: '/var/lib/mysql'
  end
end
