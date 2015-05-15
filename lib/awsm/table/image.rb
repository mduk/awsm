module Awsm
  module Table 
    class Image < TableBase

      def defaultHeadings
        {
          image_id: 'Image ID',
          name: 'Name',
          location: 'Location',
          creation_date: 'Creation Date',
          public: 'Public',
          architecture: 'Architecture',
          image_type: 'Image Type',
          description: 'Description',
          hypervisor: 'Hypervisor'
        }
      end

      def defaultFields
        {
          image_id: -> (i) { i.image_id },
          name: -> (i) { i.name },
          location: -> (i) { i.image_location },
          creation_date: -> (i) { i.creation_date },
          public: -> (i) { i.public },
          architecture: -> (i) { i.architecture },
          image_type: -> (i) { i.image_type },
          description: -> (i) { i.description },
          hypervisor: -> (i) { i.hypervisor }
        }
      end

      def config
        Awsm::instance_table_config
      end

    end
  end
end
