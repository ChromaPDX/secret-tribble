Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE distributions (
        distribution_id VARCHAR(32) PRIMARY KEY,
        pool_id VARCHAR(32) NOT NULL,
        account_id VARCHAR(32) NOT NULL,
        split_pct DECIMAL(5,4) NOT NULL,
        created_at TIMESTAMP NOT NULL
      )
    eos
    
    add_index :distributions, :created_at
    add_index :distributions, :pool_id
    add_index :distributions, :account_id
  end

  down do
    drop_table :distributions
  end
end
