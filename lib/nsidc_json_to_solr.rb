
# Translates NSIDC JSON format to Solr JSON add format
class NsidcJsonToSolr
  DATA_CENTER_LONG_NAME = 'National Snow and Ice Data Center'
  DATA_CENTER_SHORT_NAME = 'NSIDC'

  def translate(json_doc)
    copy_keys = %w(title summary)
    solr_add_hash = json_doc.select { |k, v| copy_keys.include?(k) }
    solr_add_hash.merge!(
      'authoritative_id' => json_doc['authoritativeId'],
      'dataset_version' => json_doc['majorVersion']['version'],
      'data_centers' => DATA_CENTER_LONG_NAME,
      'facet_data_center' => "#{DATA_CENTER_LONG_NAME} | #{DATA_CENTER_SHORT_NAME}"
      # task 709 start

      # task 709 end
      # task 710 start

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
end
