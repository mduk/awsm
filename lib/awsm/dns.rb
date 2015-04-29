require 'aws-sdk-core'

module Awsm
  class Dns
    def initialize
      @client = Aws::Route53::Client.new
      @dns_map_by_target = {}
      @records = []
      load_dns_records
    end

    def find_for( target )
      @dns_map_by_target[ target ]
    end

    def get_by_record( record )
      @records.select do |r|
        r.name =~ /^#{record}/
      end
    end

    def load_dns_records
      paged_response = @client.list_resource_record_sets(
        hosted_zone_id: Awsm::dns_config.hosted_zone
      )

      paged_response.each_page do |p|
        records = p.resource_record_sets.select do |r|
          r.type == 'A' || r.type == 'CNAME'
        end

        records.each do |r|
          if r.resource_records == []
            target = r.alias_target.dns_name
          else
            target = r.resource_records[0].value
          end

          @dns_map_by_target[target] = r.name
          @records << r
        end
      end
    end
  end
end
