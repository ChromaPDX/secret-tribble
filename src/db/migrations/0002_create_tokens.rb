Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE tokens (
        token_id VARCHAR(32) PRIMARY KEY,
        account_id VARCHAR(32) NOT NULL,
        metadata TEXT,
        created_at TIMESTAMP NOT NULL
      )
    eos
    
    add_index :tokens, :token_id
    add_index :tokens, :account_id
  end

  down do
    drop_table :tokens
  end
end
