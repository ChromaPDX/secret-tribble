Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE IF NOT EXISTS distributions (
        distribution_id VARCHAR(32) PRIMARY KEY,
        pool_id VARCHAR(32) NOT NULL,
        account_id VARCHAR(32) NOT NULL,
        split_pct NUMERIC(5, 1) NOT NULL,
        created_at TIMESTAMP NOT NULL
      )
    eos
    add_index created_at
    add_index pool_id
  end

  down do
    drop_table :distributions
  end
end
