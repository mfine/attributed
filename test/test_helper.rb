require "sequel"
require "securerandom"

require "attributed/autoload"
require "attributed/data_helper"

ENV['DATABASE_URL'] = "postgres://localhost/attributed-dev"

Sequel.extension :migration
Attributed::DataHelper.init

class Hash
  def reverse_merge(hash)
    hash.merge(self)
  end
end

def uuid
  SecureRandom.uuid
end

def hex
  SecureRandom.hex
end

def truncate_tables
  (Attributed::DataHelper.db.tables - [:schema_migrations]).each do |table|
    Attributed::DataHelper.db.run("TRUNCATE TABLE #{table} CASCADE")
  end
end
