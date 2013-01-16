# Production-specific deployment rules.
set :application_url, "limey"

set :user, 'ubuntu'

role :app, application_url
role :web, application_url
role :db,  application_url, :primary => true
