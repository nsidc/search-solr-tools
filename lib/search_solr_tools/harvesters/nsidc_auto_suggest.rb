# frozen_string_literal: true

require_relative 'auto_suggest'

module SearchSolrTools
  module Harvesters
    class NsidcAutoSuggest < AutoSuggest
      def harvest_and_delete
        puts 'Building auto-suggest indexes for NSIDC'
        super(method(:harvest), 'source:"NSIDC"', @env_settings[:auto_suggest_collection_name])
      end

      def harvest
        url = "#{solr_url}/#{@env_settings[:collection_name]}/select?q=*%3A*&fq=source%3ANSIDC&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1"
        super url, fields
      end

      def fields
        {
          'authoritative_id' => { weight: 1, source: 'NSIDC', creator: method(:standard_add_creator) },
          'full_title'       => { weight: 2, source: 'NSIDC', creator: method(:standard_add_creator) },
          'copy_parameters'  => { weight: 5, source: 'NSIDC', creator: method(:standard_add_creator) },
          'full_platforms'   => { weight: 2, source: 'NSIDC', creator: method(:short_full_split_add_creator) },
          'full_sensors'     => { weight: 2, source: 'NSIDC', creator: method(:short_full_split_add_creator) },
          'full_authors'     => { weight: 1, source: 'NSIDC', creator: method(:standard_add_creator) }
        }
      end

      def short_full_split_add_creator(value, count, field_weight, source)
        add_docs = []
        value.split(' > ').each do |v|
          add_docs.concat(standard_add_creator(v, count, field_weight, source))
        end
        add_docs
      end
    end
  end
end
