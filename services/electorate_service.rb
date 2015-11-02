require 'httparty'

class ElectorateService
  include HTTParty

  def initialize(electorate_name)
    @electorate_name = electorate_name
  end

  def request_payload
    {
      query: {
        bool: {
          must: [
            {
              query_string: {
                default_field: "slug",
                query: @electorate_name
              }
            }
          ]
        }
      }
    }
  end

  def get_mesh_blocks
    ElectorateService.post('https://site:a1534a534ef72b948437133ae441e134@kili-eu-west-1.searchly.com/_search', request_payload)
  end
end