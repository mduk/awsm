module Awsome
  class AutoScalingGroups
    def initialize
      @client = Aws::AutoScaling::Client.new
      @asg_map = {}
      load_auto_scaling_groups
    end

    def find_for( elb_name )
      @asg_map[ elb_name ]
    end

    def load_auto_scaling_groups
      @client.describe_auto_scaling_groups.each_page do |p|
        p.auto_scaling_groups.map do |asg|
          asg.load_balancer_names.each do |elb_name|
            @asg_map[elb_name] = [] if @asg_map[elb_name].nil?
            @asg_map[elb_name] << {
              asg_name: asg.auto_scaling_group_name,
              instances: asg.instances.map{ |i| i.to_h },
              instance_ids: asg.instances.map { |i| i.instance_id }
            }
          end
        end
      end
    end
  end
end
