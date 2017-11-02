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

ActiveRecord::Schema.define(version: 20171101202536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classroom_records", force: :cascade do |t|
    t.integer  "classroom_id", null: false
    t.integer  "user_id",      null: false
    t.string   "role",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "active",       null: false
    t.index ["classroom_id", "user_id"], name: "index_classroom_records_on_classroom_id_and_user_id", unique: true, using: :btree
  end

  create_table "classrooms", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "course_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug",       null: false
    t.integer  "user_limit"
    t.index ["slug"], name: "index_classrooms_on_slug", unique: true, using: :btree
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
    t.string   "subtitle"
    t.string   "slug",                                      null: false
    t.boolean  "public",                    default: false, null: false
    t.boolean  "disable_task_submissions",  default: false, null: false
    t.index ["slug"], name: "index_courses_on_slug", unique: true, using: :btree
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
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
    t.string   "title",                                    null: false
    t.integer  "position",                                 null: false
    t.integer  "section_id",                               null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "content",                  default: "",    null: false
    t.text     "markdown_content",         default: "",    null: false
    t.boolean  "visible",                  default: false, null: false
    t.text     "sidebar_content"
    t.text     "markdown_sidebar_content"
  end

  create_table "lessons_quizzes", force: :cascade do |t|
    t.integer "lesson_id"
    t.integer "quiz_id"
  end

  create_table "lessons_tasks", force: :cascade do |t|
    t.integer "lesson_id"
    t.integer "task_id"
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.integer  "quiz_question_id", null: false
    t.text     "content",          null: false
    t.boolean  "correct",          null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "markdown_content", null: false
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer  "quiz_id",      null: false
    t.integer  "user_id",      null: false
    t.float    "score",        null: false
    t.text     "answers_json", null: false
    t.text     "message"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.integer  "quiz_id",              null: false
    t.text     "content",              null: false
    t.string   "question_type",        null: false
    t.string   "freetext_regex"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "explanation"
    t.text     "markdown_content",     null: false
    t.text     "markdown_explanation"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string   "title",             null: false
    t.integer  "creator_id",        null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "maximum_attempts"
    t.integer  "wait_time_seconds"
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
    t.integer  "runs_limit",  default: 8,     null: false
  end

  create_table "task_runs", force: :cascade do |t|
    t.integer  "task_id",                          null: false
    t.integer  "user_id",                          null: false
    t.text     "source_code"
    t.string   "lang",                             null: false
    t.string   "status",                           null: false
    t.string   "external_key"
    t.string   "message"
    t.text     "grader_log"
    t.integer  "memory_limit_kb",                  null: false
    t.integer  "time_limit_ms",                    null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "run_type",                         null: false
    t.float    "points",           default: 0.0,   null: false
    t.string   "display_status",                   null: false
    t.text     "compilation_log"
    t.boolean  "has_ml",           default: false, null: false
    t.boolean  "has_tl",           default: false, null: false
    t.boolean  "has_wa",           default: false, null: false
    t.boolean  "has_re",           default: false, null: false
    t.text     "re_details"
    t.boolean  "show_source_code", default: false, null: false
    t.boolean  "show_user_name",   default: false, null: false
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
    t.text     "markdown_solution"
    t.text     "solution"
    t.text     "cpp_boilerplate"
    t.text     "cpp_wrapper"
    t.text     "java_boilerplate"
    t.text     "java_wrapper"
    t.text     "python_boilerplate"
    t.text     "python_wrapper"
    t.text     "ruby_boilerplate"
    t.text     "ruby_wrapper"
  end

  create_table "user_invitations", force: :cascade do |t|
    t.string   "email",                      null: false
    t.boolean  "used",       default: false, null: false
    t.datetime "used_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["email"], name: "index_user_invitations_on_email", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: "",    null: false
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.boolean  "active",                    default: false, null: false
    t.string   "last_programming_language"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["provider"], name: "index_users_on_provider", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid"], name: "index_users_on_uid", using: :btree
  end

end
