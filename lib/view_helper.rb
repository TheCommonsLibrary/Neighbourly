require 'sinatra/base'

module Sinatra
  module ViewHelper
    module Helpers
      def body_class(body)
        body ? body : nil
      end
    end

    def self.registered(app)
      app.helpers ViewHelper::Helpers
    end
  end

  register ViewHelper
end
