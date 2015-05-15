module Awsm 
  module CLI
    class Main < Clibase
      class_option :instances, :type => :boolean, :default => false, :aliases => "-i",
        :desc => "Also show instance information. Including ID, Private IP, and current health."

      class_option :dns, :type => :boolean, :default => false, :aliases => "-d",
        :desc => "Check if there are any Route53 records pointing at this Load Balancer"

      class_option :asg, :type => :boolean, :default => false, :aliases => "-a",
        :desc => "Show Auto Scaling Groups that are receiving traffic from this Load Balancer"

      desc 'spin', 'Ad-hoc instances'
      subcommand 'spin', Awsm::CLI::Spin

      desc 'unused', 'Find unused resources'
      subcommand 'unused', Awsm::CLI::Unused

      desc 'tag', 'Search by tags'
      subcommand 'tag', Awsm::CLI::Tag

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
        results = load_balancers.getAll.select do |combined|
          combined[:elb][:name] =~ /#{search_terms}/
        end
        results = do_options( results )
        results.each { |elb| print_result(elb) }
      end

      desc "r53 [dns-name]",
        "Show me what <dns-name> points at."
      def r53( dns_name )
        dns_len = dns_name.length

        say "#{dns_name} ", :yellow
        say "=> ", :bold
        dns.get_by_record( dns_name ).each_with_index do |r, i|
        if i > 0
          say " " * ( dns_len + 4 )
        end
        say "(#{r.type}) ", :green
        case r.type
          when "A"
            say "#{r.alias_target.dns_name}", :cyan
          end
        end
      end

    no_commands do
      def load_balancers
        Awsm::LoadBalancers.new
      end

      def instances
        Awsm::Instances.new
      end

      def dns
        Awsm::Dns.new
      end

      def asg
        Awsm::AutoScalingGroups.new
      end

      def do_options( results )
        if options[:instances]
          results.map do |combined|
            instance_data = Awsm::Instances.new.get_instance_data( combined[:elb_instance_ids] )
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

        # DNS
        if result[:r53_dns].nil?
          say result[:elb][:dns], :white, false
        else
          say result[:r53_dns], :bold, false
        end

        puts

        # Load Balancer Tags
        say "  NO TAGS!", :red  unless result[:elb][:tags].length > 0
        say "  Tags:" if result[:elb][:tags].length > 0
        result[:elb][:tags].each do |k, v|
          print '       '
          say k, :cyan, false
          print ' => '
          say v, :yellow
        end

        if options[:instances]
          if result[:instances] != []
            say "  Instances:"
            result[:instances].each do |instance_and_id|
              instance = instance_and_id[1]
              print_instance( 12, instance )
            end
          else
            say "  No Instances!", :red
          end
        end

	# Auto Scaling Groups
	if options[:asg]
	  say "  Auto Scaling Groups:"
	end
        if options[:asg] and result[:asgs].nil?
	  say "    No Auto Scaling Groups!", :red
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
end
