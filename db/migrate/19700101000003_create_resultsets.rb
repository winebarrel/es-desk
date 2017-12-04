class CreateResultsets < ActiveRecord::Migration[5.1]
  def change
    create_table :resultsets do |t|
      t.string :index_name, null: false
      t.text :index_definition, null: false
      t.references :dataset, foreign_key: {on_delete: :cascade}
      t.text :dataset_preview, null: false
      t.text :query, null: false
      t.text :result, null: false
      t.timestamps
      t.index :created_at, name: 'idx_created_at'
    end
  end
end
