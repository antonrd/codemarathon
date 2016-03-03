# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160303075349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classroom_records", force: :cascade do |t|
    t.integer  "classroom_id", null: false
    t.integer  "user_id",      null: false
    t.string   "role",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "classrooms", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "course_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string   "title",                                     null: false
    t.text     "markdown_description",                      null: false
    t.text     "description",                               null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "markdown_long_description",                 null: false
    t.text     "long_description",                          null: false
    t.boolean  "visible",                   default: false, null: false
    t.boolean  "is_main",                   default: false, null: false
  end

  create_table "lesson_records", force: :cascade do |t|
    t.integer  "lesson_id",                    null: false
    t.integer  "user_id",                      null: false
    t.integer  "classroom_id",                 null: false
    t.integer  "views",        default: 0,     null: false
    t.boolean  "covered",      default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string   "title",                            null: false
    t.integer  "position",                         null: false
    t.integer  "section_id",                       null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "content",          default: "",    null: false
    t.text     "markdown_content", default: "",    null: false
    t.boolean  "visible",          default: false, null: false
  end

  create_table "lessons_tasks", force: :cascade do |t|
    t.integer "lesson_id"
    t.integer "task_id"
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "role_type",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "course_id",                  null: false
    t.string   "title",                      null: false
    t.integer  "position",                   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "visible",    default: false, null: false
  end

  create_table "task_records", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "task_id",                     null: false
    t.float    "best_score",  default: 0.0,   null: false
    t.integer  "best_run_id"
    t.boolean  "covered",     default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "task_runs", force: :cascade do |t|
    t.integer  "task_id",                       null: false
    t.integer  "user_id",                       null: false
    t.text     "source_code"
    t.string   "lang",                          null: false
    t.string   "status",                        null: false
    t.string   "external_key"
    t.string   "message"
    t.text     "grader_log"
    t.integer  "memory_limit_kb",               null: false
    t.integer  "time_limit_ms",                 null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "run_type",                      null: false
    t.float    "points",          default: 0.0, null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "title",                                null: false
    t.string   "task_type",                            null: false
    t.text     "markdown_description",                 null: false
    t.text     "description",                          null: false
    t.integer  "creator_id",                           null: false
    t.boolean  "visible",              default: false, null: false
    t.string   "external_key"
    t.integer  "memory_limit_kb",                      null: false
    t.integer  "time_limit_ms",                        null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end
