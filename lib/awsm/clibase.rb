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
    end
  end
end
