require 'thor'

module Awsm
  class Spin < Thor 

    desc 'up [AMI_ID]',
      "Spin up an instance of the specified AMI"
    def up( ami_id )
      say "Spinning up #{ami_id}..."
      response = ec2.run_instances(
        image_id: ami_id,
        min_count: 1,
        max_count: 1,
        key_name: 'magi-cucumber',
        instance_type: 't2.micro',
        security_group_ids: [ 'sg-961d01fa' ], # Staging
        subnet_id: 'subnet-20e3d466' # Staging
      )

      instance_id = response.instances.first.instance_id
      say "Instance #{instance_id} is spinning up...", :green

      while instance_extant?( instance_id ) == false
        say '.', :green, false
        sleep(3)
      end

      tags = [
        { key: 'Name', value: "Temporary instance of #{ami_id} for #{whoami}" },
        { key: 'awsm:owner', value: whoami },
        { key: 'mendeley:contact', value: 'dkendell' },
        { key: 'mendeley:environment', value: 'development' },
      ]

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
    def list
      response = ec2.describe_instances(
        filters: [
          { name: 'tag-key', values: [ "awsm:owner" ] }
        ]
      )
      response.reservations.each do |r|
        r.instances.each do |i|
          owner = i.tags.select { |t| t.key == 'awsm:owner' }.first.value
          colour = case i.state.name
            when 'running'
              :green
            when 'terminated'
              :red
            else
              :yellow
          end

          parts = [ i.instance_id, i.state.name, i.image_id, owner, i.launch_time ]

          if i.state.name == 'running'
            parts << i.private_ip_address
          end

          say parts.join(' '), colour
        end
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
    end
  end
end
