module Awsm

  def self.configure
    @@c = Configulator.new
    yield @@c
  end

  def self.spin_config( preset=nil )
    @@c.spin( preset )
  end

  def self.dns_config
    @@c.dns
  end

  def self.instance_table_config
    @@c.instance_table
  end

  class InstanceTablutron

    def initialize
      @use_fields = []
      @fields = {}
    end

    def use_fields( fields=nil )
      if fields.nil?
        return @use_fields
      end

      @use_fields = fields
    end

    def add_field( name, heading, &block )
      @fields[ name ] = {
        heading: heading,
        block: block
      }
    end

    def fields
      return @fields
    end

  end

  class Configulator

    def initialize
      @spin_blocks = {}
      @dns_block = nil
    end

    def instance_table
      if block_given?
        @instance_tablutron = InstanceTablutron.new
        yield @instance_tablutron
      else
        @instance_tablutron
      end
    end

    def dns( &block )
      if block_given?
        @dns_block = block
        return
      end

      c = Domainatrix.new
      @dns_block.call( c )
      return c
    end

    def spin( preset=nil, &block )
      if block_given?
        if preset.nil?
          preset = 'default'
        end

        @spin_blocks[ preset ] = block
        return
      end

      if preset.nil? || preset == 'default'
        preset = 'default'
        c = Spinulator.new
      else
        c = Spinulator.new( spin('default') )
      end

      if @spin_blocks[ preset ].nil?
        raise StandardError, "Invalid preset: #{preset}"
      end

      @spin_blocks[ preset ].call( c )

      return c

    end

  end

  class Domainatrix

    def hosted_zone( zone=nil )
      if zone.nil?
        return @hosted_zone
      end

      @hosted_zone = zone
    end

  end

  class Spinulator

    def initialize( default=nil )
      @config = { tags: {} }
      if default
        @config[:instance_type] = default.instance_type
        @config[:key_name] = default.key_name
        @config[:subnet] = default.subnet
        @config[:security_groups] = default.security_groups
        @config[:tags] = default.tags || {}
      end
    end

    def method_missing( name, *args )
      n_args = args.length

      write = ( n_args > 0 || block_given? )

      if write
        if block_given?
          args << yield
        end

        @config[ name ] = args.first
      else
        return @config[ name ]
      end
    end

    def tag( name, value=nil )
      if value.nil? && block_given?
        @config[:tags][ name ] = yield
      elsif value && !block_given?
        @config[:tags][ name ] = value
      elsif value.nil? && !block_given?
        raise StandardError, "You need to specify something."
      elsif !value.nil? && block_given?
        raise StandardError, "You can't specify both a value and a block. Choose."
      end
    end

    def security_group( security_group )
      if @config[:security_groups].nil?
        @config[:security_groups] = []
      end

      if security_group.nil? && block_given?
        @config[:security_groups] << yield
      elsif security_group && !block_given?
        @config[:security_groups] << security_group
      elsif security_group.nil? && !block_given?
        raise StandardError, "You need to specify something."
      elsif !security_group.nil? && block_given?
        raise StandardError, "You can't specify both a value and a block. Choose."
      end
    end

  end

end

