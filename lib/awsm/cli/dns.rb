module Awsm
  module CLI
    class Dns < Clibase

      desc 'list', 'list'
      method_option :type, :type => :string, :default => 'A,CNAME,MX'
      method_option :record, :type => :string, :default => nil
      def list
        r53 = Aws::Route53::Client.new

        record_sets = []
        r53.list_hosted_zones_by_name.hosted_zones.each do |hz|
          r53.list_resource_record_sets( hosted_zone_id: hz.id )
            .resource_record_sets.each do |rrs|
            record_sets << rrs
          end
        end

        types = []
        unless options[:type].nil?
          types = options[:type].dup.upcase.split( ',' )
          record_sets.select! do |rrs|
            types.include?( rrs.type )
          end
        end

        records = []
        unless options[:record].nil?
          records = options[:record].dup.split( ',' )
          record_sets.select! do |rrs|
            records.include?( rrs.name )
          end
        end

        record_sets.each do |rrs|
          say "#{rrs.name} ", :green
          say "(#{rrs.type})", :yellow
          unless rrs.alias_target.nil?
            say "\t #{rrs.alias_target.dns_name}"
          else
            rrs.resource_records.each do |rr|
              say "\t #{rr.value}"
            end
          end
        end

      end

    end
  end
end
