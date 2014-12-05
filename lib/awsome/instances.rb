module Awsome
  class Instances
    def initialize
      @client = Aws::EC2::Client.new
    end

    def get_instance_data( instance_ids )
      descriptions = @client.describe_instances( {
        filters: [
          { name: "instance-id", values: instance_ids }
        ]
      } ).reservations.first.instances

      instance_hash = {}
      descriptions.each do |description|
        instance_hash[ description.instance_id ] = description.to_h
      end
      instance_hash
    end
  end
end
