namespace :environment do
  task :common do
    set :name, 'mongodb'
    set :image, 'mongo'
    host 'dockhost01.yzguy.io'
  end

  desc 'Production environment'
  task :production => :common do
    set_current_environment(:production)
    host_port 27017, container_port: 27017
    host_volume '/opt/mongodb_data', container_volume: '/data/db'
  end
end
