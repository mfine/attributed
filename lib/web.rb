require "unicorn"
require "monkey_patch"

require "attributed/log"
require "attributed/data_helper"
require "attributed/web"

module Web
  extend self, Attributed::Log

  def port
    @port ||= ENV['PORT']
  end

  def server
    @server ||= Unicorn::HttpServer.new(Attributed::Web, to_options)
  end

  def run
    notice port: port
    Attributed::DataHelper.init
    server.start.join
  end

  def to_options
    { listeners: ["0.0.0.0:#{port}"],
      worker_processes: 8,
      timeout: 1.hours }
  end

end
