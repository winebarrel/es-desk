class CreateDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :datasets do |t|
      t.string :name, null: false
      t.string :index_name, null: false
      t.string :document_type, null: false
      t.mediumblob :data, null: false
      t.timestamps
      t.index :name, name: 'idx_name', unique: true
    end
  end
end
