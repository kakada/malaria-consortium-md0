# rvm pkg install readline
# rvm reinstall 1.9.2 --with-readline-dir=$rvm_path/usr
# create shared/config/database.yml
# create database


require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user

#use malaria-consortium as our dir name
set :application, "malaria-consortium"

set :repository,  "git@github.com:chenwebdev/referral-system.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names

#user for bitbucket(default local user)
# set :scm_username, "chen.webdev@gmail.com"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# ssh user for remote server
set :user , "ilab"
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true


server '192.168.1.102', :app, :web, :db , :primary => true

set :deploy_to, "/var/www/#{application}"

before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'


after "deploy", "deploy:bundle_install"
after "deploy:bundle_install", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:restart"

before "deploy:start", "deploy:migrate"
before "deploy:restart", "deploy:migrate"

after "deploy:finalize_update", "deploy:symlink_configs"

namespace :deploy do 
  
  task :bundle_install do
    #run "cd #{deploy_to}/current && gem install bundler" 
  end
  
  task :bundle_gems do
    run "cd #{deploy_to}/current && bundle install"
  end
  
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :symlink_configs, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end