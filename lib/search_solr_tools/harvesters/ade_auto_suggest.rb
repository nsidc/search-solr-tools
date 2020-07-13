require_relative 'auto_suggest'

module SearchSolrTools
  module Harvesters
    class AdeAutoSuggest < AutoSuggest
      def harvest_and_delete
        puts 'Building auto-suggest indexes for ADE'
        super(method(:harvest), 'source:"ADE"', @env_settings[:auto_suggest_collection_name])
      end

      def harvest
        url = "#{solr_url}/#{@env_settings[:collection_name]}/select?q=*%3A*&fq=source%3AADE&fq=spatial:[45.0,-180.0+TO+90.0,180.0]&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1"
        super url, fields
      end

      def fields
        {
          'full_keywords_and_parameters' => { weight: 2, source: 'ADE', creator: method(:keyword_creator) },
          'full_authors' => { weight: 1, source: 'ADE', creator: method(:author_creator) }
        }
      end

      def split_creator(value, count, field_weight, source, split_regex)
        add_docs = []
        value.downcase.split(split_regex).each do |v|
          v = v.strip.chomp('/')
          add_docs.concat(ade_length_limit_creator(v, count, field_weight, source)) unless v.nil? || v.empty?
        end
        add_docs
      end

      def keyword_creator(value, count, field_weight, source)
        split_creator value, count, field_weight, source, %r{/ [\/ \>]+ /}
      end

      def author_creator(value, count, field_weight, source)
        split_creator value, count, field_weight, source, %r{/;/}
      end

      def ade_length_limit_creator(value, count, field_weight, source)
        return [] if value.length > 80
        standard_add_creator value, count, field_weight, source
      end
    end
  end
end
