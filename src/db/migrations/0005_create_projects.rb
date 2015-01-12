Sequel.migration do
  up do
    App.db.run <<-eos
      CREATE TABLE projects (
        project_id VARCHAR(32) NOT NULL,
        user_id VARCHAR(32) NOT NULL,
        pool_id VARCHAR(32) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        name TEXT NOT NULL
      )
    eos
    
    add_index :projects, :project_id
    add_index :projects, :created_at
    add_index :projects, :pool_id
  end

  down do
    drop_table :projects
  end
end
