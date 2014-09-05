require 'rest-client'
require './lib/harvester_base'
require './lib/selectors/nsidc_json_to_solr'
require 'json'

# Use the nsidc_oai core to populate the auto_suggest core
class AutoSuggestHarvester < HarvesterBase
  def initialize(env = 'development')
    super env
    @environment = env
    @env_settings = SolrEnvironments[@environment]
  end

  def harvest_and_delete_nsidc
    puts 'Building auto-suggest indexes for NSIDC'
    harvest_and_delete(method(:harvest_nsidc), "source:\"NSIDC\"", @env_settings[:auto_suggest_collection_name])
  end

  def harvest_and_delete_ade
    puts 'Building auto-suggest indexes for ADE'
    harvest_and_delete(method(:harvest_ade), "source:\"ADE\"", @env_settings[:auto_suggest_collection_name])
  end

  def harvest_nsidc
    url = "#{solr_url}/#{@env_settings[:collection_name]}/select?q=*%3A*&fq=source%3ANSIDC&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1"
    fields = nsidc_fields
    harvest url, fields
  end

  def harvest_ade
    url = "#{solr_url}/#{@env_settings[:collection_name]}/select?q=*%3A*&fq=source%3AADE&fq=spatial:[45.0,-180.0+TO+90.0,180.0]&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1"
    fields = ade_fields
    harvest url, fields
  end

  private

  def harvest(url, fields)
    facet_response = fetch_auto_suggest_facet_data(url, fields)
    add_docs = generate_add_hashes(facet_response, fields)
    add_documents_to_solr(add_docs)
  end

  def short_full_split_add_creator(value, count, field_weight, source)
    add_docs = []
    value.split(' > ').each do |v|
      add_docs.concat(standard_add_creator(v, count, field_weight, source))
    end
    add_docs
  end

  def ade_split_creator(value, count, field_weight, source, split_regex)
    add_docs = []
    value.downcase.split(split_regex).each do |v|
      v = v.strip.chomp('/')
      add_docs.concat(ade_length_limit_creator(v, count, field_weight, source)) unless v.nil? || v.empty?
    end
    add_docs
  end

  def ade_keyword_creator(value, count, field_weight, source)
    ade_split_creator value, count, field_weight, source, / [\/ \>]+ /
  end

  def ade_author_creator(value, count, field_weight, source)
    ade_split_creator value, count, field_weight, source, /;/
  end

  def ade_length_limit_creator(value, count, field_weight, source)
    return [] if value.length > 80

    standard_add_creator value, count, field_weight, source
  end

  def standard_add_creator(value, count, field_weight, source)
    count_weight = count <= 1 ? 0.4 : Math.log(count)
    weight = field_weight * count_weight
    [{ 'id' => "#{source}:#{value}", 'text_suggest' => value, 'source' => source, 'weight' => weight }]
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
        new_docs = fields[facet_name][:creator].call(facet_value[0], facet_value[1], fields[facet_name][:weight], fields[facet_name][:source])
        add_docs.concat(new_docs)
      end
    end
    add_docs
  end

  def add_documents_to_solr(add_docs)
    if insert_solr_doc add_docs, HarvesterBase::JSON_CONTENT_TYPE, @env_settings[:auto_suggest_collection_name]
      puts "Added #{add_docs.size} auto suggest documents in one commit"
    else
      puts "Failed adding #{add_docs.size} documents in single commit, retrying one by one"
      new_add_docs = []
      add_docs.each do |doc|
        new_add_docs << { 'add' => { 'doc' => doc } }
      end
      insert_solr_docs new_add_docs, HarvesterBase::JSON_CONTENT_TYPE, @env_settings[:auto_suggest_collection_name]
    end
  end

  def nsidc_fields
    { 'authoritative_id' => { weight: 1, source: 'NSIDC', creator: method(:standard_add_creator) },
      'full_title' => { weight: 2, source: 'NSIDC', creator: method(:standard_add_creator) },
      'copy_parameters' => { weight: 5, source: 'NSIDC', creator: method(:standard_add_creator) },
      'full_platforms' => { weight: 2, source: 'NSIDC', creator: method(:short_full_split_add_creator) },
      'full_sensors' => { weight: 2, source: 'NSIDC', creator: method(:short_full_split_add_creator) },
      'full_authors' => { weight: 1, source: 'NSIDC', creator: method(:standard_add_creator) } }
  end

  def ade_fields
    { 'full_keywords_and_parameters' => { weight: 2, source: 'ADE', creator: method(:ade_keyword_creator) },
      'full_authors' => { weight: 1, source: 'ADE', creator: method(:ade_author_creator) } }
  end
end
