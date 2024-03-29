require 'serverspec'
require 'net/ssh'
require 'json'
require 'yaml'
require ENV['ATDD_SOURCE_DIRECTORY']+'/commands/templates/serverspec/types/atddmemcache.rb'
require ENV['ATDD_SOURCE_DIRECTORY']+'/commands/templates/serverspec/types/atddredis.rb'
require ENV['ATDD_SOURCE_DIRECTORY']+'/commands/templates/serverspec/types/atddbeanstool.rb'
require ENV['ATDD_SOURCE_DIRECTORY']+'/commands/templates/serverspec/types/atddmysql.rb'
require ENV['ATDD_SOURCE_DIRECTORY']+'/commands/templates/serverspec/types/atddmongod.rb'


playbook_directory= ENV['ATDD_PLAYBOOK_DIRECTORY']
app_name = ENV['APP_NAME']
file = File.read(ENV['ATDD_EXTRA_VARS_VERIFY_ROLES_JSON'])
properties = JSON.parse(file)

host_info="#{playbook_directory}/.log/#{app_name}/ansible_tdd_inventory.yml"
if File.exist?(host_info)
  properties['hosts'] =YAML.load_file(host_info)
end

set_property properties

set :backend, :ssh
set :request_pty, true

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['ATDD_TARGET_HOST']

options = Net::SSH::Config.for(host)

options[:user] = ENV['ATDD_ANSIBLE_SSH_USER']
if ENV['SSH_CUSTOM_KEY']
  options[:keys] = ENV['SSH_CUSTOM_KEY']
end

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

