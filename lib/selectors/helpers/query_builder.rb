# Class to build a query string based on a hash of params
class QueryBuilder
  class << self
    def build(params)
      "?#{ params.map { |k, v| "#{ k }=#{ v }" }.join('&') }"
    end
  end
end
