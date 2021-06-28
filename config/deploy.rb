# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "rails-react-demo"
set :repo_url, "git@github.com:vitormcid/rails-react-demo.git"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/www/rails-react-demo"

# Default value for :linked_files is []
append :linked_files, "config/database.yml",  "config/master.key"
append :linked_files, 'config/database.yml',  '.env'
# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

# Default value for keep_releases is 5
set :keep_releases, 5

# Rbenv
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.5.5'

# Nvm/Node.JS
set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v10.16.3'
set :nvm_map_bins, %w{node npm yarn}
set :yarn_flags, '--silent --no-progress'

# # Passenger
set :passenger_roles, :app
set :passenger_restart_runner, :sequence
set :passenger_restart_wait, 10
set :passenger_restart_limit, 2
set :passenger_restart_with_sudo, false
set :passenger_environment_variables, {RAILS_ENV: 'production'}
set :passenger_restart_command, 'passenger stop --pid-file "/home/deploy/www/rails-react-demo/current/tmp/pids/passenger.3000.pid" && passenger start --daemonize --address 127.0.0.1 --port 3000'
set :passenger_restart_options, -> { "#{deploy_to}/current" }

# Nginx
set :nginx_roles, :web
set :nginx_sudo_paths, []
set :nginx_sudo_tasks, ['nginx:restart']

# Used to build for optimized production
namespace :deploy do
  task :yarn_build do
    on roles fetch(:yarn_roles) do
      within fetch(:yarn_target_path, release_path) do
        execute fetch(:yarn_bin), 'install'
        execute fetch(:yarn_bin), 'build'
      end
    end
  end
  desc 'Restart application'
  task :restart do
    on roles fetch(:nginx_roles) do
      execute :sudo, '/etc/init.d/nginx restart'
    end
  end
  before 'symlink:release', :yarn_build
  after :finishing, :restart
end