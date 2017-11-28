class CreateIndexMetadata < ActiveRecord::Migration[5.1]
  def change
    create_table :index_metadata do |t|
      t.string :index_name, null: false
      t.references :dataset, foreign_key: {on_delete: :cascade}
      t.timestamps
      t.index :index_name, name: 'idx_index_name', unique: true
    end
  end
end
