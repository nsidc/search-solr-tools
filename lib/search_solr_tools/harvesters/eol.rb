require_relative './ade_harvester'

class EolHarvester < ADEHarvester
  def initialize(env = 'development', die_on_failure = false)
    super env, 'EOL', die_on_failure
  end
end
