require './lib/ade_harvester.rb'
require './lib/nodc_harvester.rb'
require './lib/echo_harvester.rb'
require './lib/ices_harvester.rb'
require './lib/auto_suggest_harvester.rb'

namespace :harvest do

  desc 'Harvest all ADE data, including auto-suggest'
  task :all_ade, :environment do |t, args|
    Rake::Task['harvest:cisl'].invoke(args[:environment])
    Rake::Task['harvest:echo'].invoke(args[:environment])
    Rake::Task['harvest:eol'].invoke(args[:environment])
    Rake::Task['harvest:ices'].invoke(args[:environment])
    Rake::Task['harvest:nmi'].invoke(args[:environment])
    Rake::Task['harvest:nodc'].invoke(args[:environment])
    Rake::Task['harvest:rda'].invoke(args[:environment])
    Rake::Task['harvest:ade_auto_suggest'].invoke(args[:environment])
  end

  desc 'Harvest auto suggest for ADE'
  task :ade_auto_suggest, :environment do |t, args|
    harvester = AutoSuggestHarvester.new args[:environment]
    harvester.harvest_and_delete_ade
  end

  desc 'Harvest CISL data'
  task :cisl, :environment do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'CISL')
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for CISL: #{e.message}'
      next
    end
  end

  desc 'Harvest ECHO data'
  task :echo, :environment do |t, args|
    begin
      harvester = EchoHarvester.new args[:environment]
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for ECHO: #{e.message}'
      next
    end
  end

  desc 'Harvest EOL data'
  task :eol, :environment do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'EOL')
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for EOL: #{e.message}'
      next
    end
  end

  desc 'Harvest ICES data'
  task :ices, :environment do |t, args|
    begin
      harvester = IcesHarvester.new args[:environment]
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for ICES: #{e.message}'
      next
    end
  end

  desc 'Harvest NMI data'
  task :nmi, :environment do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'NMI')
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for NMI: #{e.message}'
      next
    end
  end

  desc 'Harvest NODC data'
  task :nodc, :environment do |t, args|
    begin
      harvester = NodcHarvester.new args[:environment]
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for NODC: #{e.message}'
      next
    end
  end

  desc 'Harvest RDA data'
  task :rda, :environment do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'RDA')
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for RDA: #{e.message}'
      next
    end
  end

  desc 'Harvest ADE data from GI-Cat'
  task :ade, :environment, :profile do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], args[:profile])
      harvester.harvest_and_delete
    rescue
      puts 'Harvest failed for #{args[:profile]}: #{e}'
      next
    end
  end
end
