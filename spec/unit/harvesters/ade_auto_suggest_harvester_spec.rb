require 'spec_helper'

describe SearchSolrTools::Harvesters::AdeAutoSuggest, :skip => "Obsolete harvester, would need to be updated to new status handling method" do
  describe 'harvest_nsidc' do
    it 'harvests from ade and inserts into auto_suggest' do
      auto_suggest_harvester = described_class.new 'integration'

      stub_request(:get, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai/select?q=*%3A*&fq=source%3AADE&fq=spatial:[45.0,-180.0+TO+90.0,180.0]&rows=0&wt=json&indent=true&facet=true&facet.mincount=1&facet.sort=count&facet.limit=-1&facet.field=full_authors')
        .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => GZIP_DEFLATE_IDENTITY })
        .to_return(status: 200, body: File.open('spec/unit/fixtures/ade_auto_suggest_solr_harvest_query.json'), headers: {})

      stub_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with(body: /[{.*}]/)
        .to_return(status: 200, body: 'success', headers: {})

      auto_suggest_harvester.harvest

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('"id":"ADE:u.s. geological survey","text_suggest":"u.s. geological survey","source":"ADE","weight"') }).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
          .with { |req| req.body.include?('"id":"ADE:donald a. (skip) walker","text_suggest":"donald a. (skip) walker","source":"ADE","weight":') }).to have_been_made

      expect(a_request(:post, 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest/update?commit=true')
        .with { |req| req.body.include?('"id":"ADE:earth science > atmosphere > atmospheric water vapor","text_suggest":"earth science > atmosphere > atmospheric water vapor","source":"ADE","weight"') }).to have_been_made
    end
  end
end
