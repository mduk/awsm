module Awsm
  module Table 
    class Instance < TableBase

      def defaultHeadings
        {
          instance_id: 'Instance ID',
          name: 'Name',
          state: 'State',
          image_id: 'Image ID',
          launch_time: 'Launch Time',
          private_ip: 'Private IP',
          awsm_owner: 'Owner'
        }
      end

      def defaultFields
        {
          instance_id: -> (i) { i.instance_id },
          name: -> (i) { tag( 'Name', i.tags ).first },
          state: -> (i) { i.state.name },
          image_id: -> (i) { i.image_id },
          launch_time: -> (i) { i.launch_time },
          private_ip: -> (i) { i.private_ip_address },
          awsm_owner: -> (i) { tag( 'awsm:owner', i.tags ).first }
        }
      end

      def config
        Awsm::table_config( :instance )
      end

    end
  end
end
