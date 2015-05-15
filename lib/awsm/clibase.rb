module Awsm
  class Clibase < Thor
    no_commands do

      def puts_table( table )
        if options[:tables] == true
          puts Terminal::Table.new( table )
        else
          table[:rows].each do |r|
            puts r.join( ' ' )
          end
        end
      end

      def ec2
        Aws::EC2::Client.new
      end

      def filter_instances( filters )
        instances = []
        ec2.describe_instances( filters: filters ).reservations.each do |r|
          r.instances.each do |i|
            instances << i
          end
        end
        instances
      end

      def filter_images( filters )
        images = []
        ec2.describe_images( filters: filters ).images.each do |i|
          images << i
        end
        images
      end

    end
  end
end
