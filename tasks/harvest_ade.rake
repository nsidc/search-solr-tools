require './lib/ade_harvester.rb'
require './lib/nodc_harvester.rb'
require './lib/echo_harvester.rb'
require './lib/ices_harvester.rb'

namespace :harvest do

  desc 'Harvest all ADE data'
  task :all_ade, :environment do |t, args|
    Rake::Task['harvest:cisl'].invoke(args)
    Rake::Task['harvest:echo'].invoke(args)
    Rake::Task['harvest:eol'].invoke(args)
    Rake::Task['harvest:ices'].invoke(args)
    Rake::Task['harvest:nmi'].invoke(args)
    Rake::Task['harvest:nodc'].invoke(args)
    Rake::Task['harvest:rda'].invoke(args)
  end

  desc 'Harvest CISL data'
  task :cisl, :environment do |t, args|
    harvester = ADEHarvester.new(args[:environment], 'CISL')
    harvester.harvest_gi_cat_into_solr
  end

  desc 'Harvest ECHO data'
  task :echo, :environment do |t, args|
    harvester = EchoHarvester.new args[:environment]

    harvester.harvest_echo_into_solr
  end

  desc 'Harvest EOL data'
  task :eol, :environment do |t, args|
    harvester = ADEHarvester.new(args[:environment], 'EOL')
    harvester.harvest_gi_cat_into_solr
  end

  desc 'Harvest ICES data'
  task :ices, :environment do |t, args|
    harvester = IcesHarvester.new args[:environment]

    harvester.harvest_ices_into_solr
  end

  desc 'Harvest NMI data'
  task :nmi, :environment do |t, args|
    harvester = ADEHarvester.new(args[:environment], 'NMI')
    harvester.harvest_gi_cat_into_solr
  end

  desc 'Harvest NODC data'
  task :nodc, :environment do |t, args|
    harvester = NodcHarvester.new args[:environment]

    harvester.harvest_nodc_into_solr
  end

  desc 'Harvest RDA data'
  task :rda, :environment do |t, args|
    harvester = ADEHarvester.new(args[:environment], 'RDA')
    harvester.harvest_gi_cat_into_solr
  end

  desc 'Harvest ADE data from GI-Cat'
  task :ade, :environment, :profile do |t, args|
    harvester = ADEHarvester.new(args[:environment], args[:profile])
    harvester.harvest_gi_cat_into_solr
  end
end
