require 'httparty'

module AwsLambda
  class Connection
    def initialize
      @lambda_url = ENV['LAMBDA_BASE_URL'] + '/territories/'
    end

    def execute(query)
      url_json = "#{@lambda_url}bounds?nwx=#{query['nelng']}&nwy=#{query['nelat']}&sex=#{query['swlng']}&sey=#{query['swlat']}"
      response = HTTParty.get(url_json)
      JSON.parse response.body
    end
  end
end
