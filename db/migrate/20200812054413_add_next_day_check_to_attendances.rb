class AddNextDayCheckToAttendances < ActiveRecord::Migration[5.1]
  def change
     add_column :attendances, :next_day_check, :string, default: "0"
  end
end
