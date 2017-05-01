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

ActiveRecord::Schema.define(version: 20170501125420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boats", force: :cascade do |t|
    t.string   "name"
    t.string   "boat_type_name"
    t.integer  "sail_number"
    t.string   "vhf_call_sign"
    t.string   "ais_mmsi"
    t.integer  "external_id"
    t.string   "external_system"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

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

  create_table "handicaps", force: :cascade do |t|
    t.string   "name"
    t.float    "handicap"
    t.datetime "best_before"
    t.string   "source"
    t.float    "srs"
    t.string   "registry_id"
    t.integer  "sail_number"
    t.string   "boat_name"
    t.string   "owner_name"
    t.string   "external_system"
    t.integer  "external_id"
    t.string   "type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "organizers", force: :cascade do |t|
    t.string   "name"
    t.string   "email_from"
    t.string   "name_from"
    t.string   "email_to"
    t.text     "confirmation"
    t.string   "external_id"
    t.string   "external_system"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
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
    t.string   "name"
  end

  create_table "regattas", force: :cascade do |t|
    t.string   "name"
    t.string   "email_from"
    t.string   "name_from"
    t.string   "email_to"
    t.text     "confirmation"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "active",          default: false
    t.integer  "organizer_id"
    t.string   "external_id"
    t.string   "external_system"
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "race_id"
    t.integer  "external_id"
    t.string   "external_system"
    t.string   "name"
    t.string   "boat_name"
    t.string   "boat_type_name"
    t.string   "boat_sail_number"
    t.integer  "start_point"
    t.integer  "start_number"
    t.float    "plaque_distance"
    t.boolean  "did_not_start"
    t.boolean  "did_not_finish"
    t.boolean  "paid_fee"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "boat_id"
    t.boolean  "active",           default: false
    t.integer  "finish_point"
    t.boolean  "offshore",         default: false
    t.string   "vacancies"
    t.integer  "handicap_id"
    t.string   "handicap_type"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "role",                              default: 0,     null: false
    t.time     "deleted_at"
    t.integer  "person_id"
    t.boolean  "review",                            default: false
    t.string   "authentication_token",   limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["person_id"], name: "index_users_on_person_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
