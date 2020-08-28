class AddIndexToOfficesOfficeNumber < ActiveRecord::Migration[5.1]
  def change
    add_index :offices, :office_number, unique: true
  end
end
