class AddChangeAttendanceToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_superior_id, :integer
    add_column :attendances, :change_status, :string
    add_column :attendances, :chenge_check, :string, default: "0"
    add_column :attendances, :change_approval, :integer, default: 1
    add_column :attendances, :change_next_day_check, :string, default: "0"
  end
end
