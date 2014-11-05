Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE revenue (
        revenue_id VARCHAR(32) PRIMARY KEY,
        pool_id VARCHAR(32) NOT NULL,
        amount DECIMAL(14, 4) NOT NULL,
        currency VARCHAR(3) NOT NULL,
        created_at TIMESTAMP NOT NULL
      )
    eos

    add_index :revenue, :pool_id
    add_index :revenue, :created_at
  end

  down do
    drop_table :revenue
  end

end
