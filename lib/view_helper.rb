require 'sinatra/base'

module Sinatra
  module ViewHelper
    module Helpers
      def body_class(body)
        body ? body : nil
      end

      def versioned_stylesheet(stylesheet)
        "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join("public", "stylesheets", "#{stylesheet}.css")).to_i.to_s
      end

      def versioned_javascript(js)
        "/javascript/#{js}.js?" + File.mtime(File.join("public", "javascript", "#{js}.js")).to_i.to_s
      end

      def is_admin?(email)
        domains = ENV['PRIMARY_DOMAINS'].split(",").map(&:strip)
        domains.any? { |domain| email.include?(domain) }
      end
    end

    def self.registered(app)
      app.helpers ViewHelper::Helpers
    end
  end

  register ViewHelper
end
