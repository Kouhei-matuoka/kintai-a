# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200813090000) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "superior_id"
    t.string "status"
    t.datetime "month_apply"
    t.integer "month_approval", default: 1
    t.string "month_check", default: "0"
    t.integer "overtime_superior_id"
    t.string "overtime_status"
    t.datetime "overtime_end_plan"
    t.string "overtime_check", default: "0"
    t.integer "overtime_approval", default: 1
    t.string "overtime_detail"
    t.string "next_day_check", default: "0"
    t.string "overtime_hours"
    t.integer "change_superior_id"
    t.string "change_status"
    t.string "change_check", default: "0"
    t.integer "change_approval", default: 1
    t.string "change_next_day_check", default: "0"
    t.datetime "changed_started_at"
    t.datetime "changed_finished_at"
    t.datetime "approval_date"
    t.date "calendar_day"
    t.string "superior_name"
    t.string "overtime_superior_name"
    t.string "change_superior_name"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.integer "office_number"
    t.string "office_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_number"], name: "index_offices_on_office_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2020-08-14 23:00:00"
    t.datetime "work_time", default: "2020-08-14 22:30:00"
    t.boolean "admin", default: false
    t.boolean "superior", default: false
    t.string "uid"
    t.integer "employee_number"
    t.datetime "designated_work_start_time", default: "2020-08-15 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-08-15 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
