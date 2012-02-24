require "sequel"

require "attributed/log"
require "attributed/error"

module Attributed
  class Attribute < Sequel::Model
    include Log
    extend Log

    plugin :timestamps
    unrestrict_primary_key
    def_column_accessor :txid_snapshot_xmin

    def since
      [txid, txid_snapshot_xmin].min
    end

    def state
      deleted_at ? "off" : "on"
    end

    def to_h
      { service_name: service_name,
        name: name,
        entity_name: entity_name,
        state: state,
        since: since }
    end

    def set_deleted_at(value)
      set deleted_at: value
      save_changes
    end

    def self.find_or_create(cond, &block)
      notice cond do
        raise InvalidArguments unless (cond.keys - [:service_name, :name, :entity_name]).empty?
        if entry = filter(cond).first
          entry.set_deleted_at nil
        else
          create(cond, &block)
        end
      end
    end

    def self.find_and_delete(cond)
      notice cond do
        raise InvalidArguments unless (cond.keys - [:service_name, :name, :entity_name]).empty?
        if entry = filter(cond).first
          entry.set_deleted_at Sequel.datetime_class.now
        end
      end
    end

    def self.on(datas)
      datas.each(&method(:find_or_create))
    end

    def self.off(datas)
      datas.each(&method(:find_and_delete))
    end

    def self.dump(datas)
      since = datas.delete(:since).to_i
      raise InvalidArguments unless (datas.keys - [:service_name, :name, :entity_name]).empty?
      find_since(since, datas).each do |entry|
        yield entry.to_h
        since = entry.txid_snapshot_xmin
      end
    end

    def self.feed(datas)
      since = datas.delete(:since).to_i
      raise InvalidArguments unless (datas.keys - [:service_name, :name, :entity_name]).empty?
      find_since(since, datas).each do |entry|
        yield entry.to_h
        since = entry.txid_snapshot_xmin
      end
      loop do
        find_since(since, datas).each do |entry|
          yield entry.to_h
          since = entry.txid_snapshot_xmin
        end
        yield nil
        sleep 1
      end
    end

    dataset_module do
      def find_since(since, cond)
        cond = cond.merge(deleted_at: nil) if since.zero?
        select("txid_snapshot_xmin(txid_current_snapshot()), *".lit)
          .filter(cond)
          .filter{txid >= since}
          .order(:txid)
      end
    end

  end
end
