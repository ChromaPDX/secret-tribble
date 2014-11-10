Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE queues (
        topic VARCHAR(32) NOT NULL,
        message_id VARCHAR(32) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        body TEXT NOT NULL
      )
    eos
    
    add_index :queues, :topic
    add_index :queues, :created_at
    add_index :queues, :message_id
  end

  down do
    drop_table :queues
  end
end
