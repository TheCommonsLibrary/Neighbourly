require 'sinatra/base'

module Sinatra
  module NationBuilder
    module Helpers
      def nation_slug(slug=nil)
        if slug.nil?
          session[:nation_slug]
        else
          session[:nation_slug] = slug
        end
      end

      def nation_token(token=nil)
        if token.nil?
          session[:nation_token]
        else
          session[:nation_token] = token
        end
      end

      def site_path
        "https://#{nation_slug}.nationbuilder.com"
      end

      def query_nationbuilder(path)
        JSON.parse(HTTParty.get("https://#{nation_slug}.nationbuilder.com/api/v1/#{path}?access_token=#{nation_token}").body)
      end

      def authorised?
        !nation_slug.nil? and !nation_token.nil? 
      end

      def authorised
        if authorised?
          yield
        else
          flash[:notice] = 'You need to login before you can view that page.'
          redirect '/'
        end
      end
    end

    def self.registered(app)
      app.helpers NationBuilder::Helpers
    end
  end

  register NationBuilder
end
