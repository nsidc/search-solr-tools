require_relative './ade_harvester'

class NmiHarvester < ADEHarvester
  def initialize(env = 'development', die_on_failure = false)
    super env, 'NMI', die_on_failure
  end
end
