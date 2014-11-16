Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE ledger (
        ledger_id VARCHAR(32) PRIMARY KEY,
        created_at TIMESTAMP NOT NULL,
        to_wallet_id VARCHAR(32) NOT NULL,
        from_wallet_id VARCHAR(32) NOT NULL,
        amount DECIMAL(14, 4) NOT NULL,
        balance DECIMAL(14, 4),
        pool_id VARCHAR(32) NOT NULL,
        project_id VARCHAR(32) NOT NULL,
        origin TEXT,
        transaction_id VARCHAR(32) NOT NULL
      )
    eos

    add_index :ledger, :ledger_id
    add_index :ledger, :created_at
    add_index :ledger, :to_wallet_id
    add_index :ledger, :from_wallet_id
    add_index :ledger, :pool_id
    add_index :ledger, :project_id
    add_index :ledger, [:to_wallet_id, :from_wallet_id, :transaction_id], :unique => true
  end

  down do
    drop_table :ledger
  end
end
