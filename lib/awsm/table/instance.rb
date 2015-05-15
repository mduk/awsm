module Awsm
  module Table
    class Instance

      def initialize( instances, fields = [ :instance_id, :name, :state, :image_id, :launch_time, :private_ip ] )
        @fields = fields
        @rows = instances.map do |i|
          row = []
          @fields.each do |f|
            row << extract_field( i, f )
          end
          row
        end
      end

      def print
        puts Terminal::Table.new(
          headings: @fields.map { |f| heading( f ) },
          rows: @rows
        )
      end

      private

      def extract_field( instance, field )
        case field
          when :instance_id
            instance.instance_id
          when :name
            tag( 'Name', instance.tags ).first
          when :state
            instance.state.name
          when :image_id
            instance.image_id
          when :launch_time
            instance.launch_time
          when :private_ip
            if instance.state.name == "running"
              instance.private_ip_address
            else
              'N/A'
            end
          when :awsm_owner
            tag( 'awsm:owner', instance.tags ).first
          else
            raise StandardError "Unknown field"
        end
      end

      def heading( field )
        headings = {
          instance_id: 'Instance ID',
          name: 'Name',
          state: 'State',
          image_id: 'Image ID',
          launch_time: 'Launch Time',
          private_ip: 'Private IP',
          awsm_owner: 'Owner'
        }
        headings[ field ]
      end

      def tag( key, tags )
        tags.select { |t| t.key == key }
          .map { |t| t.value }
      end

    end
  end
end
