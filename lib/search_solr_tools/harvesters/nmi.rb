require_relative './ade'

module SearchSolrTools
  module Harvesters
    class Nmi < ADE
      def initialize(env = 'development', die_on_failure = false)
        super env, 'NMI', die_on_failure
      end
    end
  end
end
