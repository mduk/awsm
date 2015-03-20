require 'pry'

module Awsm
  module CLI

    class Prune < Thor

      desc "elasticloadbalancers",
        "Find and prune elastic load balancers that aren't connected to anything"
      def elasticloadbalancers
        find_instanceless_elbs.map do |elb|
          [ elb.load_balancer_name, elb.dns_name, elb.created_time ]
        end
        puts Terminal::Table.new(
          headings: [ "ELB Name", "DNS", "Created Time" ],
          rows: find_instanceless_elbs.map do |elb|
            [ elb.load_balancer_name, elb.dns_name, elb.created_time ]
          end
        )
      end

      no_commands do
        def elb
          Aws::ElasticLoadBalancing::Client.new
        end

        def find_instanceless_elbs
          elbs = []
          elb.describe_load_balancers.load_balancer_descriptions.each do |elb|
            if elb.instances.length == 0
              elbs << elb
            end
          end
          elbs
        end
      end
    
    end

  end
end
