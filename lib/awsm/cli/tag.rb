module Awsm
  module CLI
    class Tag < Clibase

      desc 'find tag=value [tag=] [=value] [...]',
        "Find instances by tags."
      method_option :fields, :type => :string
      method_option :format, :type => :string, :default => :pretty
      def find( *args )
        if args == []
          say "Please specify at least one tag=/=value/tag=value"
          return
        end
        fields = nil
        if !options[:fields].nil?
          fields = options[:fields].split(',').map { |f| f.to_sym }
        end

        format = :pretty
        if !options[:format].nil?
          format = options[:format].to_sym
        end

        Table::Instance.new( filter_instances( argsToFilters( args ) ), fields, format ).print
      end

      desc 'list [resource_id]',
        "List tags for resource."
      def list( resource_id )
        print_tags( case resource_id
          when /^i-[0-9a-f]+/
            filter_instances( [ { name: 'instance-id', values: [ resource_id ] } ] ).first.tags
          when /^ami-[0-9a-f]+/
            filter_images( [ { name: 'image-id', values: [ resource_id ] } ] ).first.tags
          else
            raise StandardError, "Unknown resource id format: #{resource_id}"
        end )
      end

      no_commands do

        def argsToFilters( args )
          tags = {}
          filters = args.map do |arg|
            key, value = arg.split( '=' )

            if tags[ key ].nil?
              tags[ key ] = []
            end

            tags[ key ] << value
          end

          filters = []
          tags.each do |k, v|
            v = v.select { |e| !e.nil? }.uniq
            if k == ""
              filters << { name: 'tag-value', values: v }
            else
              if v == []
                filters << { name: 'tag-key', values: [ k ] }
              else
                filters << { name: "tag:#{k}", values: v }
              end
            end
          end

          filters
        end

        def print_tags( tags )
          tags.each do |t|
            say "#{t.key} => #{t.value}"
          end
        end

      end

    end
  end
end
