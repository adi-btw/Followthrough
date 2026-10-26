# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_26_201000) do
  create_table "care_plans", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.date "start_date", null: false
    t.boolean "needs_follow_up", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "check_in_token", null: false
    t.index ["check_in_token"], name: "index_care_plans_on_check_in_token", unique: true
    t.index ["patient_id"], name: "index_care_plans_on_patient_id"
  end

  create_table "check_ins", force: :cascade do |t|
    t.integer "recommendation_id", null: false
    t.date "taken_on", null: false
    t.boolean "taken", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slot", default: "morning", null: false
    t.index ["recommendation_id", "taken_on", "slot"], name: "index_check_ins_on_recommendation_date_and_slot", unique: true
    t.index ["recommendation_id"], name: "index_check_ins_on_recommendation_id"
  end

  create_table "patients", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_patients_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer "care_plan_id", null: false
    t.string "name", null: false
    t.string "dose", null: false
    t.integer "times_per_day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["care_plan_id"], name: "index_recommendations_on_care_plan_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "care_plans", "patients"
  add_foreign_key "check_ins", "recommendations"
  add_foreign_key "patients", "users"
  add_foreign_key "recommendations", "care_plans"
  add_foreign_key "sessions", "users"
end
