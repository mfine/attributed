require "sequel"

module Attributed
  module DataHelper
    extend self

    def url
      @url ||= ENV['DATABASE_URL']
    end

    def connect
      if conn = Sequel.connect(url, encoding: "unicode")
        conn.run("SET synchronous_commit TO off")
        [:attributes].each do |m|
          Sequel::Model(m)
        end
        conn
      end
    end

    def db
      @db ||= connect
    end

    def init
      db.test_connection
    end

  end
end
