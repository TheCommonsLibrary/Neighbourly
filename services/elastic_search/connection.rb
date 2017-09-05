require 'httparty'

module ElasticSearch
  class Connection
    def initialize
      @elastic_search_url = ENV['ELASTIC_SEARCH_BASE_URL']
    end

    def execute(query)
      url_json = "#{@elastic_search_url}bounds?nwx=#{query['nelng']}&nwy=#{query['nelat']}&sex=#{query['swlng']}&sey=#{query['swlat']}"
      response = HTTParty.get(url_json)
      JSON.parse response.body
    end
  end
end
