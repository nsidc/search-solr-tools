require 'search_solr_tools/harvesters/oai'

describe OaiHarvester do
  before(:each) do
    @harvester = OaiHarvester.new
  end

  describe '#initialize' do
    it 'has a nil resumption token' do
      expect(@harvester.instance_variable_get(:@resumption_token)).to be_nil
    end
  end

  describe '#encode_data_provider_url' do
    it 'returns an encoded url string' do
      expect(@harvester.encode_data_provider_url('http://this.com?thing=    ')).to eql(
        'http://this.com?thing=%20%20%20%20'
      )
    end
  end

  describe '#results' do
    it 'is not implemented on base class' do
      expect { @harvester.results }.to raise_error(NotImplementedError)
    end
  end

  describe '#metadata_url' do
    it 'is not implemented on base class' do
      expect { @harvester.metadata_url }.to raise_error(NotImplementedError)
    end
  end

  describe '#request_params' do
    it 'is not implemented on base class' do
      expect { @harvester.send(:request_params) }.to raise_error(NotImplementedError)
    end
  end

  describe '#request_string' do
    before :each do
      @harvester.instance_variable_set(:@dataset, 'test dataset')
      allow(@harvester).to receive(:request_params).and_return(verb: 'ListRecords', metadataPrefix: 'dif')
      allow(@harvester).to receive(:metadata_url).and_return('http://nsidc.org/someapi/')
    end

    it 'creates a valid request string' do
      expect(@harvester.send(:request_string)).to eql 'http://nsidc.org/someapi/?verb=ListRecords&metadataPrefix=dif'
    end
  end
end
