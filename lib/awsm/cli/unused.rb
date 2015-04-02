module Awsm
  module CLI

    class Unused < Clibase

      class_option :tables, :type => :boolean, :lazy_default => true, :default => true,
        :desc => "Whether or not to draw ASCII tables."

      desc "elasticloadbalancers",
        "Find and prune elastic load balancers that aren't connected to anything"
      def elasticloadbalancers
        puts_table(
          headings: [ "ELB Name", "DNS", "Created Time" ],
          rows: find_instanceless_elbs.map do |elb|
            [ elb.load_balancer_name, elb.dns_name, elb.created_time ]
          end
        )
      end

      desc 'launchconfigurations',
        "Find unused launch configurations"
      def launchconfigurations
        puts_table(
          headings: [ "Launch Configuration Name", "Created Time" ],
          rows: find_unused_launchconfigurations.map do |lc|
            [ lc.launch_configuration_name, lc.created_time ]
          end
        )
      end

      no_commands do
        def elb
          Aws::ElasticLoadBalancing::Client.new
        end

        def as
          Aws::AutoScaling::Client.new
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

        def find_unused_launchconfigurations
          used_launchconfiguration_names = []
          as.describe_auto_scaling_groups.auto_scaling_groups.each do |asg|
            used_launchconfiguration_names << asg.launch_configuration_name
          end

          launchconfigurations = []
          as.describe_launch_configurations.launch_configurations.each do |lc|
            unless used_launchconfiguration_names.include?( lc.launch_configuration_name )
              launchconfigurations << lc
            end
          end
          launchconfigurations
        end
      end
    
    end

  end
end
