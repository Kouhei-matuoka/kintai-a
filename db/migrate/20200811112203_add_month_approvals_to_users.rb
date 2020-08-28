class AddMonthApprovalsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :month_approval, :string, default: "0"
  end
end
