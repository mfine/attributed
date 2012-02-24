require "sinatra"
require "json"

require "attributed/log"
require "attributed/autoload"

module Attributed
  class Web < Sinatra::Base
    include Log

    disable :show_exceptions, :dump_errors, :logging

    helpers do
      def data
        @data ||= JSON.parse(request.body.read, symbolize_names: true)
      end

      def chunk(s)
        "#{s.size.to_s(16)}\r\n#{s}\r\n"
      end
    end

    ["on", "off"].each do |route|
      post "/#{route}" do
        Attribute.method(route).call(data)
        200
      end
    end

    ["dump", "feed"].each do |route|
      post "/#{route}" do
        status 202
        headers "Content-Type" => "application/json", "Transfer-Encoding" => "chunked"
        stream do |out|
          Attribute.method(route).call(data) do |entry|
            out << chunk((entry && JSON.dump(entry)).to_s << "\r\n")
          end
          out << chunk("")
        end
      end
    end

    error do
      case e = env['sinatra.error']
      when InvalidArguments
        [422, "Invalid Attributes\r\n"]
      else
        exception e
        500
      end
    end

    not_found do
      [404, "Not Found\r\n"]
    end

  end
end
