class AddNameToResultset < ActiveRecord::Migration[5.1]
  def change
    add_column :resultsets, :name, :string, first: true
    change_column_null :resultsets, :name, false, Time.now
  end
end
