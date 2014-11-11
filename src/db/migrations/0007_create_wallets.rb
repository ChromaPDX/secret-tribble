Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE wallets (
        wallet_id VARCHAR(32) PRIMARY KEY,
        account_id VARCHAR(32) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        kind VARCHAR(16) NOT NULL,
        identifier TEXT NOT NULL,
        currency VARCHAR(3) NOT NULL
      )
    eos
    
    add_index :wallets, :wallet_id
    add_index :wallets, :account_id
    add_index :wallets, :kind
    add_index :wallets, :identifier
    add_index :wallets, :currency
  end

  down do
    drop_table :wallets
  end
end
