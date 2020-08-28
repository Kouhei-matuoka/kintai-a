class ChangeDatatypeOvertimeHoursOfAttendances < ActiveRecord::Migration[5.1]
  def change
     change_column :attendances, :overtime_hours, :string
  end
end
