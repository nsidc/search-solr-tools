require './lib/selectors/iso_to_solr_format'

# Translates NSIDC JSON format to Solr JSON add format
class NsidcJsonToSolr
  DATA_CENTER_LONG_NAME = 'National Snow and Ice Data Center'
  DATA_CENTER_SHORT_NAME = 'NSIDC'

  def translate(json_doc)
    copy_keys = %w(title summary keywords)
    solr_add_hash = json_doc.select { |k, v| copy_keys.include?(k) }
    solr_add_hash.merge!(
      'authoritative_id' => json_doc['authoritativeId'],
      'dataset_version' => json_doc['majorVersion']['version'],
      'data_centers' => DATA_CENTER_LONG_NAME,
      'facet_data_center' => "#{DATA_CENTER_LONG_NAME} | #{DATA_CENTER_SHORT_NAME}",
      # task 709 start
      'authors' => translate_personnel_to_authors(json_doc['personnel']),
      'facet_author' => translate_personnel_to_authors(json_doc['personnel']),
      'topics' => translate_iso_topic_categories(json_doc['isoTopicCategories']),
      # task 709 end
      # task 710 start
      'parameters' => translate_parameters(json_doc['parameters']),
      'full_parameters' => translate_parameters_to_string(json_doc['parameters']),
      'facet_parameter' => translate_parameters_to_facet_parameters(json_doc['parameters'])
      # task 710 end
      # task 711 start

      # task 711 end
      # task 712 start

      # task 712 end
      # task 713 start

      # task 713 end
      # task 714 start

      # task 714 end
      # task 715 start

      # task 715 end
    )
  end

  def translate_iso_topic_categories(iso_topic_categories_json)
    iso_topic_categories_json.map { |t| t['name'] } unless iso_topic_categories_json.nil?
  end

  def translate_personnel_to_authors(personnel_json)
    authors = []
    personnel_json.each do |person|
      unless person['firstName'].eql?('NSIDC') && person['lastName'].eql?('User Services')
        author_string = person['firstName']
        author_string = author_string + ' ' + person['middleName'] unless person['middleName'].to_s.empty?
        author_string = author_string + ' ' + person['lastName'] unless person['lastName'].to_s.empty?
        unless author_string.to_s.empty?
          author_string.strip!
          authors << author_string
        end
      end
    end
    authors
  end

  def translate_parameters(parameters_json)
    parameters = []
    parameters_json.each do |param_json|
      parameters.concat(generate_parameters_array(param_json))
    end
    parameters
  end

  def translate_parameters_to_string(parameters_json)
    parameters_strings = []
    parameters_json.each do |param_json|
      parameters_strings << generate_parameters_array(param_json).join(' > ')
    end
    parameters_strings.uniq!
  end

  def translate_parameters_to_facet_parameters(parameters_json)
    parameters_strings = translate_parameters_to_string(parameters_json)
    return [] if parameters_strings.nil?
    facet_params = []
    parameters_strings.each do |str|
      facet_params << IsoToSolrFormat.parameter_binning(str)
    end
    facet_params
  end

  def generate_parameters_array(param_json)
    parameter_parts = []
    param_json.each do |k, v|
      parameter_parts << v unless v.nil? || v.empty?
    end
    parameter_parts
  end
end
