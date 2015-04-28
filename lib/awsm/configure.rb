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
      @spin_blocks = {}
    end

    def spin( preset=nil, &block )
      if block_given?
        if preset.nil?
          preset = 'default'
        end

        @spin_blocks[ preset ] = block
      end
    end

    def get_spin( preset=nil )
      if preset.nil? || preset == 'default'
        preset = 'default'
        c = Spinulator.new
      else
        c = Spinulator.new( get_spin('default') )
      end

      if @spin_blocks[ preset ].nil?
        raise StandardError, "Invalid preset: #{preset}"
      end

      @spin_blocks[ preset ].call( c )

      return c
    end

  end

  class Spinulator

    def initialize( default=nil )
      @default = default
      @config = {}
    end

    def method_missing( name, *args )
      n_args = args.length

      write = ( n_args > 0 || block_given?)

      if write
        if block_given?
          args << yield
        end

        unless @config[ name ].nil?
          raise StandardError, "#{name} has already been set!"
        end

        @config[ name ] = args.first
      else
        if @config[ name ].nil? && @default.nil?
          raise StandardError, "#{name} has not been set."
        elsif @config[ name ].nil?
          return @default.send( name.to_sym )
        else
          return @config[ name ]
        end
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

