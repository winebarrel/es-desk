class CreateQueries < ActiveRecord::Migration[5.1]
  def change
    create_table :queries do |t|
      t.string :name, null: false
      t.text :query, null: false
      t.timestamps
      t.index :name, name: 'idx_name', unique: true
    end

    Query.create!(name: 'match_all', query: <<-JSON.strip_heredoc)
      {
        "query": {
          "match_all": {
          }
        }
      }
    JSON

    Query.create!(name: 'match_none', query: <<-JSON.strip_heredoc)
      {
        "query": {
          "match_none": {
          }
        }
      }
    JSON
  end
end
