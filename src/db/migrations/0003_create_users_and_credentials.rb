Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE users (
        user_id VARCHAR(32) PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL
      );

      CREATE TABLE credentials (
        user_id VARCHAR(32) NOT NULL,
        identifier TEXT,
        salt VARCHAR(32) NOT NULL,
        password_digest TEXT,
        kind VARCHAR(16) NOT NULL,
        created_at TIMESTAMP NOT NULL
      );
    eos
    
    add_index :users, :user_id
    add_index :credentials, :user_id
    add_index :credentials, :identifier
    add_index :credentials, :password_digest
    add_index :credentials, [:kind, :identifier], :unique => true
  end

  down do
    drop_table :users
    drop_table :credentials
  end
end
