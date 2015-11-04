require 'sinatra/base'

module Sinatra
  module ParamsHelper
    module Helpers
      def nation_param
        params['nation'] ? params['nation'].gsub(/[^a-zA-Z0-9]/, '') : nil
      end

      def code_param
        params['code'] ? params['code'].gsub(/[^a-z0-9]/, '') : nil
      end
    end

    def self.registered(app)
      app.helpers ParamsHelper::Helpers
    end
  end

  register ParamsHelper
end
