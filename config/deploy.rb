require 'mongrel_cluster/recipes'

set :application, "cachevalleysearch.com"
set :user, "demo"
set :password, "mitt96Dante"

set :domain, "67.207.129.91"
role :app, domain
role :web, domain
role :db,  domain, :primary => true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/demo/sites/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :repository, "https://mediaperfection.svn.beanstalkapp.com/cachevalleysearch/"
# set :repository, "http://svn.mediaperfection.beanstalkapp.com/cachevalleysearch/"
set :scm_username, "dlehman"
set :scm_password, "loewen"
# OLD repo on jackhamr.com
# set :repository, "http://jackhamr.com/svn/cachevalleysearch.com"
# set :scm_username, "dlehman"
# set :scm_password, "wivUjlig"

# Thew new way of telling capistrano 2.1 to use export rather than checkout
set :deploy_via, :export
set :runner, nil
set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

set :sudo, "sudo -p Password:"
# set :use_sudo, false

# namespace :deploy do
#   task :restart do
#     restart_mongrel_cluster
#   end
# end
