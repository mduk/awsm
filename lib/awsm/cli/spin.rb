module Awsm
  module CLI
    class Spin < Clibase

      class_option :tables, :type => :boolean, :lazy_default => true, :default => true,
        :desc => "Whether or not to draw ASCII tables."

      desc 'up [AMI_ID]',
        "Spin up an instance of the specified AMI"
      option :image_id
      option :key_name
      def up( preset )
        if /^ami-.+$/.match( preset )
          c = Awsm::spin_config('default')
          c.image_id( preset )
        else
          c = Awsm::spin_config( preset )
        end

        unless options[:image_id].nil?
          unless c.image_id.nil?
            override_alert( 'image_id', c.image_id, options[:image_id] )
          end
          c.image_id( options[:image_id] )
        end

        unless options[:key_name].nil?
          unless c.key_name.nil?
            override_alert( 'key_name', c.key_name, options[:key_name] )
          end
          c.key_name( options[:key_name] )
        end

        spin_up( c )
      end

      desc 'down [INSTANCE_ID]',
        "Spin down the specified instance"
      def down( instance_id )
        response = ec2.describe_instances(
          filters: [
            { name: 'instance-id', values: [ instance_id ] },
            { name: 'tag:awsm:owner', values: [ whoami ] }
          ]
        )

        if response.reservations.length == 0
          say "Instance #{instance_id} is not one of your spinning instances."
          return
        end

        say "Spinning down (terminating) #{instance_id}...", :red
        ec2.terminate_instances(
          instance_ids: [ instance_id ]
        )
      end

      desc 'list',
        "List all spinning instances"
      option :simple, :type => :boolean, :default => false, :aliases => '-s',
        :desc => "Display list without prettiness - good for sedding"
      def list
        response = ec2.describe_instances(
          filters: [
            { name: 'tag:awsm:owner', values: [ whoami ] }
          ]
        )
        spinning = []
        response.reservations.each do |r|
          r.instances.each do |i|
            owner = i.tags.select { |t| t.key == 'awsm:owner' }.first.value

            if owner == whoami
              fields = [ i.instance_id, i.state.name, i.image_id, owner, i.launch_time ]

              if i.state.name == 'running'
                fields << i.private_ip_address
              else
                fields << 'N/A'
              end

              spinning << fields
            end
          end
        end

        if options[:simple]
          spinning.each do |row|
            say row.join(' ')
          end
        else
          puts_table(
            headings: [ 'Instance ID', 'State', 'AMI ID', 'Owner', 'Launched Time', 'Private IP' ],
            rows: spinning
          )
        end
      end

      no_commands do
        def ec2
          Aws::EC2::Client.new
        end

        def whoami
          me_host = `hostname -f`.strip
          me_user = `whoami`.strip
          "#{me_user}@#{me_host}"
        end

        def override_alert( field, from, to )
          say "Overriding #{field} from #{from} to #{to}!", :bold
        end

        def instance_extant?( instance_id )
          description = ec2.describe_instances(
            instance_ids: [ instance_id ]
          )

          num_found = description.reservations.first.instances.length

          if num_found == 0
            return false
          end

          true
        end

        def spin_up( c )
          response = ec2.run_instances(
            image_id: c.image_id,
            key_name: c.key_name,
            instance_type: c.instance_type,
            security_group_ids: c.security_groups,
            subnet_id: c.subnet,
            min_count: 1,
            max_count: 1
          )

          say "Spinning up #{c.image_id}..."

          instance_id = response.instances.first.instance_id
          say "Instance #{instance_id} is spinning up...", :green

          while instance_extant?( instance_id ) == false
            say '.', :green, false
            sleep(3)
          end

          tags = [
            { key: 'Name', value: "Temporary instance of #{c.image_id} for #{whoami}" },
            { key: 'awsm:owner', value: whoami }
          ]

          c.tags.each do |k, v|
            tags << { key: k, value: v }
          end

          ec2.create_tags(
            resources: [ instance_id ],
            tags: tags
          )

          say "Tagged #{instance_id}:"
          tags.each do |tag|
            say "    #{tag[:key]} ", :cyan
            say '=> '
            say "#{tag[:value]}", :yellow
          end
        end

      end #no_commands
    end #class
  end #module
end #module
