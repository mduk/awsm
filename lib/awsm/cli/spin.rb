module Awsm
  module CLI
  class Spin < Clibase

    class_option :tables, :type => :boolean, :lazy_default => true, :default => true,
      :desc => "Whether or not to draw ASCII tables."

    desc 'up [AMI_ID]',
      "Spin up an instance of the specified AMI"
    def up( ami_id )
      say "Spinning up #{ami_id}..."
      response = ec2.run_instances(
        image_id: ami_id,
        min_count: 1,
        max_count: 1,
        key_name: configured_key_name,
        instance_type: configured_instance_type,
        security_group_ids: configured_security_groups,
        subnet_id: configured_subnet
      )

      instance_id = response.instances.first.instance_id
      say "Instance #{instance_id} is spinning up...", :green

      while instance_extant?( instance_id ) == false
        say '.', :green, false
        sleep(3)
      end

      tags = [
        { key: 'Name', value: "Temporary instance of #{ami_id} for #{whoami}" },
        { key: 'awsm:owner', value: whoami }
      ]

      configured_tags.each do |k, v|
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

    desc 'down [INSTANCE_ID]',
      "Spin down the specified instance"
    def down( instance_id )
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
          { name: 'tag-key', values: [ "awsm:owner" ] }
        ]
      )
      spinning = []
      response.reservations.each do |r|
        r.instances.each do |i|
          owner = i.tags.select { |t| t.key == 'awsm:owner' }.first.value
          fields = [ i.instance_id, i.state.name, i.image_id, owner, i.launch_time ]

          if i.state.name == 'running'
            fields << i.private_ip_address
          else
            fields << 'N/A'
          end

          spinning << fields
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

      def config
        Config.new.get('Spin')
      end

      def configured_security_groups
        config['SecurityGroups']
      end

      def configured_subnet
        config['Subnet']
      end

      def configured_instance_type
        config['InstanceType']
      end

      def configured_key_name
        config['KeyName']
      end

      def configured_tags
        config['Tags']
      end
    end
  end
end
end
