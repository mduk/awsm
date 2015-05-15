require 'yaml'
require 'thor'
require 'terminal-table'
require 'json'

require 'awsm/version'

require 'awsm/configure'

require 'awsm/loadbalancers'
require 'awsm/autoscalinggroups'
require 'awsm/dns'
require 'awsm/instances'

require 'awsm/tablebase'
require 'awsm/table/instance'
require 'awsm/table/image'

require 'awsm/clibase'
require 'awsm/cli/tag'
require 'awsm/cli/unused'
require 'awsm/cli/spin'
require 'awsm/cli/main'

require "#{ENV['HOME']}/.awsm"
