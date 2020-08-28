class AddOvertimeWorkToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_superior_id, :integer
    add_column :attendances, :overtime_status, :string
    add_column :attendances, :overtime_end_plan, :datetime
    add_column :attendances, :overtime_check, :string, default: "0"
    add_column :attendances, :overtime_approval, :integer, default: 1
    add_column :attendances, :overtime_detail, :string
  end
end
