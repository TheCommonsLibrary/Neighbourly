require 'httparty'

class ElectorateService
  include HTTParty

  def initialize(electorate_name)
    @electorate_name = electorate_name
  end

  def request_payload
    {
      fields: [],
      query: {
        term: {
            slug: @electorate_name
        }
      }
    }
  end

  def get_id
    ElectorateService.post('https://site:a1534a534ef72b948437133ae441e134@kili-eu-west-1.searchly.com/territories/territory/_search', body: request_payload.to_json)
  end
end
