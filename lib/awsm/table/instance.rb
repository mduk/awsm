module Awsm
  module Table
    class Instance

      def initialize( instances, fields=nil, format=:pretty )
        @format = format
        @use_fields = if fields.nil?
          Awsm::instance_table_config.use_fields
        else
          fields
        end

        @headings = {
          instance_id: 'Instance ID',
          name: 'Name',
          state: 'State',
          image_id: 'Image ID',
          launch_time: 'Launch Time',
          private_ip: 'Private IP',
          awsm_owner: 'Owner'
        }

        @fields = {
          instance_id: -> (i) { i.instance_id },
          name: -> (i) { tag( 'Name', i.tags ).first },
          state: -> (i) { i.state.name },
          image_id: -> (i) { i.image_id },
          launch_time: -> (i) { i.launch_time },
          private_ip: -> (i) { i.private_ip_address },
          awsm_owner: -> (i) { tag( 'awsm:owner', i.tags ).first }
        }

        Awsm::instance_table_config.fields.each do |name, field|
          @headings[ name ] = field[:heading]
          @fields[ name ] = field[:block]
        end

        @rows = instances.map do |i|
          row = []
          @use_fields.each do |f|
            row << extract_field( i, f )
          end
          row
        end
      end

      def print
        case @format
          when :pretty
            puts Terminal::Table.new(
              headings: @use_fields.map { |f| @headings[ f ] },
              rows: @rows
            )
          when :tsv
            @rows.each do |row|
              puts row.join("\t")
            end
          when :csv
            @rows.each do |row|
              puts row.join(',')
            end
          when :json
            json = []
            @rows.each do |row|
              json << Hash[ @use_fields.zip( row ) ]
            end
            puts JSON.generate( json )
          else
            puts "Unknown output format: #{@format}"
        end
      end

      private

      def extract_field( instance, field )
        @fields[ field ].call( instance )
      end

      def tag( key, tags )
        tags.select { |t| t.key == key }
          .map { |t| t.value }
      end


    end
  end
end
