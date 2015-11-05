require "sinatra/base"
require "sinatra/cookies"

module Sinatra
  module LoginHelper
    module Helpers
      def authorise(email)
        cookies[:user_email] = email
      end

      def authorised?
        email_set = cookies.has_key?(:user_email)
        email_set && settings.db[:users].where(email: cookies[:user_email]).any?
      end

      def authorised
        if authorised?
          yield
        else
          flash[:notice] = "You need to login before you can view that page."
          redirect "/"
        end
      end
    end

    def self.registered(app)
      app.helpers LoginHelper::Helpers
    end
  end

  register LoginHelper
end
