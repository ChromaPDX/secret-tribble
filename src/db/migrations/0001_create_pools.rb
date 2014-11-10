Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE pools (
        pool_id VARCHAR(32) NOT NULL,
        user_id VARCHAR(32) NOT NULL,
        split_pct DECIMAL(5,4) NOT NULL,
        created_at TIMESTAMP NOT NULL
      )
    eos
    
    add_index :pools, :created_at
    add_index :pools, :pool_id
    add_index :pools, :user_id
  end

  down do
    drop_table :pools
  end
end
