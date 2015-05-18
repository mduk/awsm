require 'aws-sdk'
require 'yaml'
require 'thor'
require 'terminal-table'
require 'json'

require 'awsm/version'

require 'awsm/configure'

require 'awsm/loadbalancers'
require 'awsm/autoscalinggroups'
require 'awsm/instances'

require 'awsm/tablebase'
require 'awsm/table/instance'
require 'awsm/table/image'

require 'awsm/clibase'
require 'awsm/cli/tag'
require 'awsm/cli/dns'
require 'awsm/cli/unused'
require 'awsm/cli/spin'
require 'awsm/cli/main'

if !File.exists?( "#{ENV['HOME']}/.awsm.rb" )
  puts "A configuration file is required at ~/.awsm.rb"
  puts "See https://github.com/mduk/awsm/blob/master/README.md for an example config file."
  exit
end

require "#{ENV['HOME']}/.awsm"
