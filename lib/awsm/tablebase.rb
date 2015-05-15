module Awsm
  class TableBase

    def initialize( instances, format=:pretty )
      @instances = instances
      @format = format

      @use_fields = config.use_fields
      @fields = defaultFields
      @headings = defaultHeadings
    end

    def print
      config.fields.each do |name, field|
        @headings[ name ] = field[:heading]
        @fields[ name ] = field[:block]
      end

      @rows = @instances.map do |i|
        row = []
        @use_fields.each do |f|
          row << extract_field( i, f )
        end
        row
      end

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
