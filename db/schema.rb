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

ActiveRecord::Schema.define(version: 20171213111200) do

  create_table "datasets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "index_name", null: false
    t.string "document_type", null: false
    t.binary "data", limit: 16777215, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["index_name"], name: "idx_index_name"
    t.index ["name"], name: "idx_name", unique: true
  end

  create_table "index_metadata", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "index_name", null: false
    t.bigint "dataset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dataset_id"], name: "index_index_metadata_on_dataset_id"
    t.index ["index_name"], name: "idx_index_name", unique: true
  end

  create_table "queries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.text "query", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_name", unique: true
  end

  create_table "resultsets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "index_name", null: false
    t.text "index_definition", null: false
    t.bigint "dataset_id"
    t.text "dataset_preview"
    t.text "query", null: false
    t.text "result", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_created_at"
    t.index ["dataset_id"], name: "index_resultsets_on_dataset_id"
  end

  add_foreign_key "index_metadata", "datasets", on_delete: :cascade
  add_foreign_key "resultsets", "datasets", on_delete: :cascade
end
