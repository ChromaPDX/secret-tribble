Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE accounts (
        account_id VARCHAR(32) PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL
      );

      CREATE TABLE credentials (
        account_id VARCHAR(32) NOT NULL,
        identifier TEXT,
        salt VARCHAR(32) NOT NULL,
        password_digest TEXT,
        kind VARCHAR(16) NOT NULL,
        created_at TIMESTAMP NOT NULL
      );
    eos
    
    add_index :accounts, :account_id
    add_index :credentials, :account_id
    add_index :credentials, :identifier
    add_index :credentials, :password_digest
  end

  down do
    drop_table :accounts
    drop_table :credentials
  end
end
