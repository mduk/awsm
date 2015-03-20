module Awsm
  class Config
    def initialize
      if File.exist?( ENV['HOME'] + '/.awsm' )
        file = File.open( ENV['HOME'] + '/.awsm' ).read
        @config = YAML.load( file )
      end
    end
    def get( key )
      @config[ key ]
    end
  end
end
