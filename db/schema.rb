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

ActiveRecord::Schema.define(version: 20161228153508) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crew_members", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "team_id"
    t.boolean  "skipper",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["person_id", "team_id"], name: "index_crew_members_on_person_id_and_team_id", unique: true, using: :btree
    t.index ["person_id"], name: "index_crew_members_on_person_id", using: :btree
    t.index ["team_id"], name: "index_crew_members_on_team_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "co"
    t.string   "street"
    t.string   "zip"
    t.string   "city"
    t.date     "birthday"
    t.string   "phone"
    t.string   "external_system"
    t.string   "external_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "country"
    t.time     "deleted_at"
    t.boolean  "review",          default: false
  end

  create_table "races", force: :cascade do |t|
    t.datetime "start_from"
    t.datetime "start_to"
    t.integer  "period"
    t.boolean  "common_finish"
    t.boolean  "mandatory_common_finish"
    t.string   "external_system"
    t.string   "external_id"
    t.integer  "regatta_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "regattas", force: :cascade do |t|
    t.string   "name"
    t.string   "organizer"
    t.string   "email_from"
    t.string   "name_from"
    t.string   "email_to"
    t.text     "confirmation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "race_id"
    t.integer  "external_id"
    t.string   "external_system"
    t.string   "name"
    t.string   "boat_name"
    t.string   "boat_class_name"
    t.string   "boat_sail_number"
    t.integer  "start_point"
    t.integer  "start_number"
    t.float    "handicap"
    t.float    "plaque_distance"
    t.boolean  "did_not_start"
    t.boolean  "did_not_finish"
    t.boolean  "paid_fee"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "role",                   default: 0,     null: false
    t.time     "deleted_at"
    t.integer  "person_id"
    t.boolean  "review",                 default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["person_id"], name: "index_users_on_person_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
