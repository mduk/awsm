module Awsm
  module CLI
    class Tag < Clibase

      desc 'find tag=value [--instances|--images] [tag=] [=value] [...]',
        "Find resources by tags."
      method_option :format, :type => :string, :default => :pretty,
        :desc => "Specify output format. [pretty|tsv|csv|json]"
      method_option :instances, :type => :boolean, :lazy_default => false,
        :desc => "Find instances matching tags."
      method_option :images, :type => :boolean, :lazy_default => false,
        :desc => "Find Images matching tags."
      def find( *args )
        if args == []
          help( :find )
          return
        end

        format = options[:format].to_sym
        filters = argsToFilters( args )

        if options[:instances]
          Table::Instance.new( filter_instances( filters ), format ).print
        end

        if options[:images]
          Table::Image.new( filter_images( filters ), format ).print
        end
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
