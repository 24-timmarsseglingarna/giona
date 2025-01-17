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

ActiveRecord::Schema.define(version: 2024_12_21_143627) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agreements", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "boats", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "boat_type_name"
    t.integer "sail_number"
    t.string "vhf_call_sign"
    t.string "ais_mmsi"
    t.integer "external_id"
    t.string "external_system"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consents", id: :serial, force: :cascade do |t|
    t.integer "agreement_id"
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agreement_id"], name: "index_consents_on_agreement_id"
    t.index ["person_id"], name: "index_consents_on_person_id"
  end

  create_table "crew_members", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "team_id"
    t.boolean "skipper", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "team_id"], name: "index_crew_members_on_person_id_and_team_id", unique: true
    t.index ["person_id"], name: "index_crew_members_on_person_id"
    t.index ["team_id"], name: "index_crew_members_on_team_id"
  end

  create_table "default_starts", id: :serial, force: :cascade do |t|
    t.integer "organizer_id"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "handicaps", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "sxk"
    t.datetime "expired_at"
    t.string "source"
    t.float "srs"
    t.string "registry_id"
    t.integer "sail_number"
    t.string "boat_name"
    t.string "owner_name"
    t.string "external_system"
    t.integer "external_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legs", id: :serial, force: :cascade do |t|
    t.integer "point_id"
    t.integer "to_point_id"
    t.float "distance"
    t.boolean "offshore", default: false
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "addtime", default: false
    t.index ["to_point_id"], name: "index_legs_on_to_point_id"
  end

  create_table "legs_terrains", id: false, force: :cascade do |t|
    t.integer "leg_id", null: false
    t.integer "terrain_id", null: false
    t.index ["leg_id", "terrain_id"], name: "index_legs_terrains_on_leg_id_and_terrain_id"
    t.index ["terrain_id", "leg_id"], name: "index_legs_terrains_on_terrain_id_and_leg_id"
  end

  create_table "logs", id: :serial, force: :cascade do |t|
    t.integer "team_id"
    t.datetime "time"
    t.integer "user_id"
    t.string "client"
    t.string "log_type"
    t.integer "point"
    t.string "data"
    t.boolean "deleted", default: false
    t.integer "gen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["team_id"], name: "index_logs_on_team_id"
    t.index ["updated_at"], name: "index_logs_on_updated_at"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "description"
    t.integer "user_id"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email_from"
    t.string "name_from"
    t.string "email_to"
    t.text "confirmation"
    t.string "external_id"
    t.string "external_system"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "web_page"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "co"
    t.string "street"
    t.string "zip"
    t.string "city"
    t.date "birthday"
    t.string "phone"
    t.string "external_system"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
    t.time "deleted_at"
    t.boolean "review", default: false
    t.boolean "skip_validation", default: true
  end

  create_table "points", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "definition"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version"
    t.string "footnote"
    t.index ["number"], name: "index_points_on_number"
  end

  create_table "points_terrains", id: false, force: :cascade do |t|
    t.integer "point_id", null: false
    t.integer "terrain_id", null: false
    t.index ["point_id", "terrain_id"], name: "index_points_terrains_on_point_id_and_terrain_id"
    t.index ["terrain_id", "point_id"], name: "index_points_terrains_on_terrain_id_and_point_id"
  end

  create_table "races", id: :serial, force: :cascade do |t|
    t.datetime "start_from"
    t.datetime "start_to"
    t.integer "period"
    t.string "external_system"
    t.string "external_id"
    t.integer "regatta_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.integer "common_finish"
    t.text "starts"
  end

  create_table "regattas", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email_from"
    t.string "name_from"
    t.string "email_to"
    t.text "confirmation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "organizer_id"
    t.string "external_id"
    t.string "external_system"
    t.integer "terrain_id"
    t.string "web_page"
    t.text "description"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.integer "race_id"
    t.integer "external_id"
    t.string "external_system"
    t.string "name"
    t.string "boat_name"
    t.string "boat_type_name"
    t.string "boat_sail_number"
    t.integer "start_point"
    t.integer "start_number"
    t.float "plaque_distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "boat_id"
    t.integer "finish_point"
    t.boolean "offshore"
    t.string "vacancies"
    t.integer "handicap_id"
    t.string "handicap_type"
    t.integer "state"
    t.integer "sailing_state", default: 0
  end

  create_table "terrains", id: :serial, force: :cascade do |t|
    t.boolean "published", default: false
    t.string "version_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.time "deleted_at"
    t.integer "person_id"
    t.boolean "review", default: false
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
