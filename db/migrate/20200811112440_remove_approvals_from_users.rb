class RemoveApprovalsFromUsers < ActiveRecord::Migration[5.1]
  def change
     remove_column :users, :month_approval, :string
  end
end
