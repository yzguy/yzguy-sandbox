namespace :environment do
  task :common do
    set :name, 'tipboard'
    set :image, 'zero1three/tipboard'
    host 'dockhost01.yzguy.io'
  end

  desc 'Production environment'
  task :production => :common do
    set_current_environment(:production)
    host_port 7272, container_port: 7272
    host_volume '/opt/tipboard', container_volume: '/root/.tipboard'
  end
end
