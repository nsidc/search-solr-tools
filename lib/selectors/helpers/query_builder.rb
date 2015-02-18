class QueryBuilder
  class << self
    def build(params)
      "?#{ params.map { |k, v| "#{ k }=#{ v }" }.join('&') }"
    end
  end
end
