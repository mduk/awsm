module Awsm

  def self.configure
    @@c = Configulator.new
    yield @@c
  end

  def self.spin_config( preset=nil )
    @@c.get_spin( preset )
  end

  class Configulator

    def initialize
      @spin = {}
    end

    def spin( preset=nil )
      if block_given?
        if preset.nil?
          preset = 'default'
          c = Spinulator.new
        else
          c = Spinulator.new( @spin['default'] )
        end

        yield c
        @spin[ preset ] = c
      else
        if preset.nil?
          preset = 'default'
        end

        return @spin[ preset ]
      end
    end

    def get_spin( preset=nil )
      if preset.nil?
        preset = 'default'
      end

      if @spin[ preset ].nil?
        raise StandardError, "Invalid preset: #{preset}"
      end

      return @spin[ preset ]
    end

  end

  class Spinulator

    def initialize( default=nil )
      @default = default
      @config = {}
      @valid_read_keys = [
        :instance_type,
        :image_id,
        :key_id,
        :subnet,
        :security_groups,
        :tags
      ]
      @valid_write_keys = [
        :instance_type,
        :image_id,
        :key_name,
        :subnet
      ]
    end

    def valid_read_key( key )
      unless @valid_read_keys.include?( name )
        raise StandardError, "#{name} is not a valid config-read key"
      end
    end

    def valid_write_key( key )
      unless @valid_write_keys.include?( name )
        raise StandardError, "#{name} is not a valid config-write key"
      end
    end
 
    def method_missing( name, *args )
      n_args = args.length

      if @config[ name ].nil? && n_args == 1 && valid_write_key( name )
        @config[ name ] = args.first
      elsif @config[ name ].nil? && n_args == 0 && block_given? && valid_write_key( name )
        @config[ name ] = yield
      elsif @config[ name ] && n_args == 0 && valid_read_key( name )
        return @config[ name ]
      elsif valid_read_key( name )
        return @default.send( name.to_sym )
      end
    end

    def to_h
      {
        instance_type: self.instance_type,
        key_name: self.key_name,
        subnet: self.subnet,
        tags: self.tags
      }
    end

    def tag( name, value=nil )
      if @config[:tags].nil?
        @config[:tags] = {}
      end

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

