module Awsm
  module CLI
    class Tag < Clibase

      desc 'find tag=value [tag2=value2] [...]',
        "Find resources by tags. Resources must have all tag key value pairs specified."
      def find( *args )
        Table::Instance.new( filter_instances( argsToFilters( args ) ) ).print
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
      end

    end
  end
end
