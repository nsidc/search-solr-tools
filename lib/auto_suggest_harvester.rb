require 'rest-client'
require './lib/harvester_base'
require './lib/selectors/nsidc_json_to_solr'
require 'json'

# Use the nsidc_oai core to populate the auto_suggest core
class AutoSuggestHarvester < HarvesterBase
  def initialize(env = 'development')
    @environment = env
    @env_settings = SolrEnvironments[@environment]
  end

  def short_full_split_add_creator(value, count, field_weight)
    add_docs = []
    value.split(' > ').each do |v|
      add_docs.concat(standard_add_creator(v, count, field_weight))
    end
    add_docs
  end

  def standard_add_creator(value, count, field_weight)
    count_weight = count <= 1 ? 0.4 : Math.log(count)
    weight = field_weight * count_weight
    [{ 'add' => { 'doc' => { 'text_suggest' => value, 'source' => 'NSIDC', 'weight' => weight } } }]
  end

  def fetch_auto_suggest_facet_data(url, fields)
    fields.each do |name, config|
      url = url + "&facet.field=#{name}"
    end

    serialized_facet_response = RestClient.get url
    JSON.parse(serialized_facet_response)
  end

  def generate_add_hashes(facet_response, fields)
    add_docs = []
    facet_response['facet_counts']['facet_fields'].each do |facet_name, facet_values|
      facet_values.each_slice(2).to_a.each do |facet_value|
        new_docs = fields[facet_name][:creator].call(facet_value[0], facet_value[1], fields[facet_name][:weight])
        add_docs.concat(new_docs)
      end
    end
    add_docs
  end

  def add_documents_to_solr(add_docs)
    insert_solr_docs add_docs, HarvesterBase::JSON_CONTENT_TYPE, @env_settings[:auto_suggest_collection_name]
  end

  def nsidc_fields
    { 'authoritative_id' => { weight: 1, creator: method(:standard_add_creator) },
      'full_title' => { weight: 2, creator: method(:standard_add_creator) },
      'copy_parameters' => { weight: 5, creator: method(:standard_add_creator) },
      'full_platforms' => { weight: 3, creator: method(:short_full_split_add_creator) },
      'full_sensors' => { weight: 3, creator: method(:short_full_split_add_creator) },
      'full_authors' => { weight: 1, creator: method(:standard_add_creator) } }
  end

  def harvest_nsidc
    url = "#{solr_url}/#{@env_settings[:collection_name]}/select?q=*%3A*&fq=source%3ANSIDC&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1"
    fields = nsidc_fields

    facet_response = fetch_auto_suggest_facet_data(url, fields)

    add_docs = generate_add_hashes(facet_response, fields)

    add_documents_to_solr(add_docs)
  end
end
