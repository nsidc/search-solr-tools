require File.join('.', 'config', 'environments.rb')
require 'webmock/rspec'
require 'oai_harvester'
require 'json'

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

  describe 'results' do
    it 'is not implemented on base class' do
      expect { @harvester.results }.to raise_error(NotImplementedError)
    end
  end

  describe 'metadata_url' do
    it 'is not implemented on base class' do
      expect { @harvester.metadata_url }.to raise_error(NotImplementedError)
    end
  end

  describe 'request_string' do
    before :each do
      @harvester.instance_variable_set(:@dataset, 'test dataset')
      allow(@harvester).to receive(:metadata_url).and_return('http://nsidc.org/someapi/')
    end

    it 'creates a valid request string' do
      expect(@harvester.send(:request_string)).to eql 'http://nsidc.org/someapi/?verb=ListRecords&metadataPrefix=dif&set=test dataset'
    end
    it 'utilizes resumes resumption token and creates a valid request string' do
      @harvester.instance_variable_set(:@resumption_token, 'foofoofoo22')
      expect(@harvester.send(:request_string)).to eql 'http://nsidc.org/someapi/?verb=ListRecords&metadataPrefix=dif&set=test dataset&resumptionToken=foofoofoo22'
    end
  end

  describe '#format_resumption_token' do
    def described_method(token)
      @harvester.send(:format_resumption_token, token)
    end

    before(:each) do
      @harvester.instance_variable_set(:@dataset, 'test dataset')
    end

    it 'returns the empty string if the token is empty' do
      expect(described_method('')).to eql ''
    end

    it 'returns a JSON string containing the offset' do
      token = 'offset:12345'
      actual = described_method(token)

      expected = {
        from: nil,
        until: nil,
        set: 'test dataset',
        metadataPrefix: 'dif',
        offset: '12345'
      }.to_json

      expect(actual).to eql expected
    end

    it 'returns a JSON string with a null offset' do
      token = 'no offset here'
      actual = described_method(token)

      expected = {
        from: nil,
        until: nil,
        set: 'test dataset',
        metadataPrefix: 'dif',
        offset: nil
      }.to_json

      expect(actual).to eql expected
    end
  end
end
