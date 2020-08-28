class RenameChengeCheckColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
     rename_column :attendances, :chenge_check, :change_check
  end
end
