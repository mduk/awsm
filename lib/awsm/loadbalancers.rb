module Awsm
  class LoadBalancers
    def initialize
      @elb_client = Aws::ElasticLoadBalancing::Client.new
      @asg_client = Aws::AutoScaling::Client.new
    end

    def get(elb_names)
      processResponse(@elb_client.describe_load_balancers({
        load_balancer_names: elb_names.split(',')
      }))
    end

    def getAll
      processResponse(@elb_client.describe_load_balancers)
    end

    private

    def processResponse(pagableResponse)
      elbs = []

      pagableResponse.each_page do |p|
        p.load_balancer_descriptions.each do |elb|
          elbs << {
            load_balancer_name: elb.load_balancer_name,
            dns_name: elb.dns_name,
            instance_ids: elb.instances.map { |i| i.instance_id }
          }
        end
      end

      combined = []
      elbs.each do |elb|
        result = {
          elb: {
            dns: elb[:dns_name],
            name: elb[:load_balancer_name],
            tags: getLoadBalancerTags( elb[:load_balancer_name] )
          },
          elb_instance_ids: elb[:instance_ids],
        }

        combined << result
      end
      combined
    end

    def getLoadBalancerTags(elb_name)
      tags = {}
      @elb_client.describe_tags( load_balancer_names: [ elb_name ] ).each_page do |p|
        p.tag_descriptions.first.tags.each do |t|
          tags[t.key] = t.value
        end
      end
      tags
    end
  end
end

