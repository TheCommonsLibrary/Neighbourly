require "sinatra/base"

module Sinatra
  module LoginHelper
    module Helpers
      def user_email
        session[:user_email]
      end

      def user_name
        # so that we dont have to do db calls every time we need a different attribute of the logged in user
        session[:user] = settings.db[:users].where(email: user_email).first if session[:user].nil?
        session[:user][:first_name].split()[0]
      end

      def authorise(email)
        #debug
        p "Auth attempt with: #{email}"
        session[:user_email] = email.downcase
      end

      def authorised?
        !user_email.nil? && settings.db[:users].where(email: user_email).any?
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
