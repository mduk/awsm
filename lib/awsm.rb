require 'yaml'
require 'thor'
require 'terminal-table'


require 'awsm/version'

require 'awsm/configure'
require 'awsm/config'

require 'awsm/loadbalancers'
require 'awsm/autoscalinggroups'
require 'awsm/dns'
require 'awsm/instances'

require 'awsm/clibase'
require 'awsm/cli/unused'
require 'awsm/cli/spin'
require 'awsm/cli/main'

require "#{ENV['HOME']}/.awsm"



