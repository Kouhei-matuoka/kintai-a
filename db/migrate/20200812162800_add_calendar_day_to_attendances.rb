class AddCalendarDayToAttendances < ActiveRecord::Migration[5.1]
  def change
     add_column :attendances, :calendar_day, :date
  end
end
