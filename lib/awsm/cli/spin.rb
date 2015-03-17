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

      me_host = `hostname -f`.strip
      me_user = `whoami`.strip

      tags = [
        { key: 'Name', value: "Temporary instance of #{ami_id} for #{me}" },
        { key: 'awsm:owner', value: "#{me_user}@#{me_host}" },
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
      say "Listing spinning...", :yellow
    end

    no_commands do
      def ec2
        Aws::EC2::Client.new
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
