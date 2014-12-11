require 'thor'

module Awsome 
  class Cli < Thor
    class_option :instances, :type => :boolean, :default => false, :aliases => "-i",
      :desc => "Also show instance information. Including ID, Private IP, and current health."
    class_option :dns, :type => :boolean, :default => false, :aliases => "-d",
      :desc => "Check if there are any Route53 records pointing at this Load Balancer"
    class_option :asg, :type => :boolean, :default => false, :aliases => "-a",
      :desc => "Show Auto Scaling Groups that are receiving traffic from this Load Balancer"

    desc "specific <comma-separated-elb-names>",
      "Only find specific ELBs named in a comma-separated list."
    def specific( elb_names )
      results = load_balancers.get(elb_names)
      results = do_options( results )
      results.each { |elb| print_result(elb) }
    end

    desc "search <search-terms>",
      "Show ELBs where the name matches the search terms."
    def search( search_terms )
      results = load_balancers.getAll.select { |combined| combined[:elb][:name] =~ /#{search_terms}/ }
      results = do_options( results )
      results.each { |elb| print_result(elb) }
    end

    no_commands do
      def load_balancers
        Awsome::LoadBalancers.new
      end

      def instances
        Awsome::Instances.new
      end

      def dns
        Awsome::Dns.new
      end

      def asg
        Awsome::AutoScalingGroups.new
      end

      def do_options( results )
        if options[:instances]
          results.map do |combined|
            instance_data = Awsome::Instances.new.get_instance_data( combined[:elb_instance_ids] )
            combined[:instances] = instance_data
          end
          say "Added instance data", :white
        end

        if options[:dns]
          results.map do |combined|
            elb_dns = combined[:elb][:dns]
            r53_dns = dns.find_for( elb_dns )
            combined[:r53_dns] = r53_dns
          end
          say "Added dns data", :white
        end

        if options[:asg]
          results.map do |combined|
            elb_name = combined[:elb][:name]
            asgs = asg.find_for( elb_name )
            combined[:asgs] = asgs
          end
        end

        results
      end

      def print_result(result)
        say result[:elb][:name], :green, false
        print ' <= '

        if result[:r53_dns].nil?
          say result[:elb][:dns], :white, false
        else
          say result[:r53_dns], :bold, false
        end

        puts

        say "  NO TAGS!", :red  unless result[:elb][:tags].length > 0
        say "  Tags:" if result[:elb][:tags].length > 0
        result[:elb][:tags].each do |k, v|
          print '       '
          say k, :cyan, false
          print ' => '
          say v, :yellow
        end

        if options[:instances]
          say "  Instances:"
          result[:instances].each do |instance_and_id|
            instance = instance_and_id[1]
            print_instance( 12, instance )
          end
        end

        if options[:asg] and !result[:asgs].nil?
          result[:asgs].each do |asg|
          enabled = result[:elb_instance_ids] & asg[:instance_ids]

          if enabled.length > 0
            say "    >> #{asg[:asg_name]} (#{asg[:instances].length})", :magenta
          else
            say "       #{asg[:asg_name]} (#{asg[:instances].length})", :magenta
          end

          if options[:instances]
            asg[:instances].each do |asg_instance|
              instance_id = asg_instance[:instance_id]
              instance_health = asg_instance[:health_status]
              instance_health_colour = ( instance_health == "Healthy" ? :green : :red )
              instance_description = result[:instances][ instance_id ]
              instance_ip = instance_description[:private_ip_address]
              unless result[:instances][ instance_id ].nil?
                say "         #{instance_id} : #{instance_ip}", instance_health_colour
              end
            end
          end
        end
      end
    end

      def print_instance( pad_length, instance )
        padding = " " * pad_length
        instance_id = instance[:instance_id]
        instance_ip = instance[:private_ip_address]
        say "#{padding}#{instance_id} : #{instance_ip}"
      end
    end
  end
end
