require 'require_all'
require_all './lib'

namespace :harvest do

  desc 'Harvest all ADE data, including auto-suggest'
  task :all_ade, :environment, :die_on_failure do |t, args|
    Rake::Task['harvest:cisl'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:echo'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:eol'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:ices'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:nmi'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:nodc'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:rda'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:usgs'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:bco_dmo'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:pdc'].invoke(args[:environment], args[:die_on_failure])
    Rake::Task['harvest:ade_auto_suggest'].invoke(args[:environment], args[:die_on_failure])
  end

  desc 'Harvest BCO-DMO data'
  task :bco_dmo, :environment, :die_on_failure do |t, args|
    begin
      harvester = BcoDmoHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for BCODMO: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest auto suggest for ADE'
  task :ade_auto_suggest, :environment, :die_on_failure do |t, args|
    harvester = AutoSuggestHarvester.new args[:environment], args[:die_on_failure]
    harvester.harvest_and_delete_ade
  end

  desc 'Harvest CISL data'
  task :cisl, :environment, :die_on_failure do |t, args|
    begin
      harvester = CislHarvester.new(args[:environment], args[:die_on_failure])
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for CISL: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest ECHO data'
  task :echo, :environment, :die_on_failure do |t, args|
    begin
      harvester = EchoHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for ECHO: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest EOL data'
  task :eol, :environment, :die_on_failure do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'EOL', args[:die_on_failure])
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for EOL: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest ICES data'
  task :ices, :environment, :die_on_failure do |t, args|
    begin
      harvester = IcesHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for ICES: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest NMI data'
  task :nmi, :environment, :die_on_failure do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'NMI', args[:die_on_failure])
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for NMI: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest NODC data'
  task :nodc, :environment, :die_on_failure do |t, args|
    begin
      harvester = NodcHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for NODC: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest RDA data'
  task :rda, :environment, :die_on_failure do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], 'RDA', args[:die_on_failure])
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for RDA: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest USGS data'
  task :usgs, :environment, :die_on_failure do |t, args|
    begin
      harvester = UsgsHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for USGS: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest Polar Data Catalog data'
  task :pdc, :environment, :die_on_failure do |t, args|
    begin
      harvester = PdcHarvester.new args[:environment], args[:die_on_failure]
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for PDC: #{e.message}"
      raise e if args[:die_on_failure]
      next
    end
  end

  desc 'Harvest ADE data from GI-Cat'
  task :ade, :environment, :profile, :die_on_failure do |t, args|
    begin
      harvester = ADEHarvester.new(args[:environment], args[:profile], args[:die_on_failure])
      harvester.harvest_and_delete
    rescue => e
      puts "Harvest failed for #{args[:profile]}: #{e}"
      raise e if args[:die_on_failure]
      next
    end
  end

end
