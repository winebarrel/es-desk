class AddDsIndexNameIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :datasets, :index_name, name: 'idx_index_name'
  end
end
