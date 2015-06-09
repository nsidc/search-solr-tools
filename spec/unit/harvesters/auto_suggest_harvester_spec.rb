require 'spec_helper'

describe SearchSolrTools::Harvesters::AutoSuggest do
  describe 'harvest_nsidc' do
    it 'harvests from nsidc_oai and inserts into auto_suggest' do
      auto_suggest_harvester = described_class.new 'integration'

      stub_request(:get, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/select?q=*%3A*&fq=source%3ANSIDC&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1&facet.field=authoritative_id&facet.field=full_title&facet.field=copy_parameters&facet.field=full_platforms&facet.field=full_sensors&facet.field=full_authors')
        .with(headers: { 'Accept' => '*/*; q=0.5, application/xml', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'Ruby' })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/nsidc_auto_suggest_solr_harvest_query.json'), headers: {})

      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with(body: /[{.*}]/)
        .to_return(status: 200, body: 'success', headers: {})

      auto_suggest_harvester.harvest_nsidc

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('"id":"NSIDC:AA_L2A","text_suggest":"AA_L2A","source":"NSIDC","weight"') }).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('AARI 10-Day Arctic Ocean EASE-Grid Sea Ice Observations') }).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('Snow/Ice') }).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('H. Jay Zwally') }).to have_been_made
    end
  end
end
