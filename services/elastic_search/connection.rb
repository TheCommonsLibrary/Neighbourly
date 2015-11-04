require 'httparty'

module ElasticSearch
  class Connection
    def initialize
      @elastic_search_url = ENV['ELASTIC_SEARCH_BASE_URL']
    end 

    def execute(query)
      response = HTTParty.get(@elastic_search_url + '/_search', body: query.to_json)
      JSON.parse response.body
    end
  end
end
