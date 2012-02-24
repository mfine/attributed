Sequel.migration do
  up do
    create_table(:attributes) do
      column :service_name, "text"
      column :name, "text"
      column :entity_name, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :deleted_at, "timestamp without time zone"
      column :txid, "bigint", default: "txid_current()".lit
      primary_key [:service_name, :name, :entity_name]
    end
    run <<-SQL
      CREATE OR REPLACE FUNCTION update_attributes_txid_column()
        RETURNS TRIGGER AS $$
        BEGIN
          IF
            ROW(NEW.created_at, NEW.updated_at, NEW.deleted_at) IS DISTINCT FROM ROW(OLD.created_at, OLD.updated_at, OLD.deleted_at)
          THEN
            NEW.txid = txid_current();
          END IF;
          RETURN NEW;
        END;
        $$ language 'plpgsql';

      CREATE TRIGGER update_attributes_txid BEFORE UPDATE ON attributes
        FOR EACH ROW
        EXECUTE PROCEDURE update_attributes_txid_column();
    SQL
  end

  down do
    run <<-SQL
      DROP TRIGGER update_attributes_txid ON attributes;
      DROP FUNCTION update_attributes_txid_column() CASCADE;
    SQL
    drop_table(:attributes)
  end
end
