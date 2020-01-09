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

ActiveRecord::Schema.define(version: 2020_01_09_121818) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "ancient_places", id: :integer, default: -> { "next_id('vocabulary'::text, 'ancient_places'::text)" }, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "parent_id"
    t.float "long"
    t.float "lat"
    t.text "full_name"
  end

  create_table "authors", id: :integer, default: -> { "next_id('vocabulary'::text, 'authors'::text)" }, force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.text "institution"
    t.text "comment"
    t.text "email"
    t.boolean "visible", default: true, null: false
  end

  create_table "collections", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "summary"
    t.bigint "place_id"
    t.index ["place_id"], name: "index_collections_on_place_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "monument_id"
    t.text "name"
    t.text "email"
    t.text "comment"
    t.datetime "created"
  end

  create_table "copyrights", id: :integer, default: -> { "next_id('vocabulary'::text, 'copyrights'::text)" }, force: :cascade do |t|
    t.string "copyright", limit: 255
  end

# Could not dump table "dating_phases_time_span" because of following StandardError
#   Unknown type 'dating_phase' for column 'phase_name'

  create_table "glossary", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "name_en"
    t.text "alternatives"
    t.text "description"
    t.boolean "iconography"
    t.boolean "epigraphy"
    t.boolean "object_type"
    t.boolean "monument_type"
  end

  create_table "literature", id: :serial, force: :cascade do |t|
    t.text "short"
    t.text "long"
    t.index ["short"], name: "literature_short_key", unique: true
  end

# Could not dump table "monuments" because of following StandardError
#   Unknown type 'object_type' for column 'object_type'

  create_table "museums", id: :integer, default: -> { "next_id('vocabulary'::text, 'museums'::text)" }, force: :cascade do |t|
    t.string "name", limit: 100
    t.integer "place_id", null: false
    t.text "short_name"
    t.text "description"
    t.text "website"
    t.index ["short_name"], name: "museums_short_name_key", unique: true
  end

  create_table "pages", id: :text, force: :cascade do |t|
    t.text "title"
    t.text "text"
    t.text "language"
    t.integer "ord"
    t.integer "photo_id"
    t.text "category"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "filename", null: false
    t.integer "monument_id"
    t.integer "regional_info_id"
    t.integer "author_id"
    t.integer "copyright_id"
    t.string "copyright_detail"
    t.string "year"
    t.text "comment"
    t.integer "ord"
    t.integer "width"
    t.integer "height"
    t.datetime "created", default: -> { "now()" }
    t.datetime "modified"
    t.index ["monument_id"], name: "photos_monument_id_idx"
  end

  create_table "places", id: :integer, default: -> { "next_id('vocabulary'::text, 'places'::text)" }, force: :cascade do |t|
    t.text "name"
    t.text "name_en"
    t.text "place_type"
    t.text "place_type_en"
    t.integer "parent_id"
    t.decimal "long"
    t.decimal "lat"
    t.text "full_name"
    t.datetime "created"
    t.datetime "modified"
  end

  create_table "queries", id: :integer, default: -> { "((('x'::text || encode(gen_random_bytes(4), 'hex'::text)))::bit(31))::integer" }, force: :cascade do |t|
    t.datetime "created", default: -> { "now()" }, null: false
    t.text "keywords"
    t.text "finding_place_legacy"
    t.text "conservation_place_legacy"
    t.text "id_ranges"
    t.text "museum"
    t.text "inscription"
    t.text "literature"
    t.text "ancient_finding_place_legacy"
    t.text "photo"
    t.text "dating"
    t.integer "finding_place_id"
    t.integer "conservation_place_id"
    t.integer "ancient_finding_place_id"
    t.text "fulltext"
    t.integer "museum_id"
    t.integer "dating_from"
    t.integer "dating_to"
  end

  create_table "regional_info_links", id: :integer, default: -> { "next_id('vocabulary'::text, 'regional_info_links'::text)" }, force: :cascade do |t|
    t.integer "regional_info_id"
    t.text "title"
    t.text "url"
  end

  create_table "regional_infos", id: :integer, default: -> { "next_id('public'::text, 'regional_info'::text)" }, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "place_id"
    t.text "text"
    t.string "address", limit: 255
    t.text "opening_hours"
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.datetime "created", default: -> { "now()" }
    t.datetime "modified"
  end

  add_foreign_key "ancient_places", "ancient_places", column: "parent_id", name: "ancient_places_parent_id_fkey"
  add_foreign_key "collections", "places"
  add_foreign_key "comments", "monuments", name: "comments_monument_id_fkey"
  add_foreign_key "monuments", "ancient_places", column: "ancient_finding_place_id", name: "monuments_ancient_finding_place_id_fkey"
  add_foreign_key "monuments", "authors", column: "archaeology_author_id", name: "monuments_archaeology_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "authors", column: "architecture_author_id", name: "monuments_architecture_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "authors", column: "epigraphy_author_id", name: "monuments_epigraphy_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "collections"
  add_foreign_key "monuments", "monuments", column: "parent_monument_id", name: "monuments_related_monument_id_fkey"
  add_foreign_key "monuments", "museums", name: "monuments_museum_id_fkey"
  add_foreign_key "monuments", "places", column: "conservation_place_id", name: "monuments_conservation_place_id_fkey"
  add_foreign_key "monuments", "places", column: "finding_place_id", name: "monuments_finding_place_id_fkey"
  add_foreign_key "monuments", "regional_infos", name: "monuments_regional_info_id_fkey"
  add_foreign_key "museums", "places", name: "museums_place_id_fkey"
  add_foreign_key "pages", "photos", name: "pages_photo_id_fkey"
  add_foreign_key "photos", "authors", name: "photos_author_id_fkey", on_update: :cascade
  add_foreign_key "photos", "copyrights", name: "photos_copyright_id_fkey"
  add_foreign_key "photos", "monuments", name: "photos_monument_id_fkey"
  add_foreign_key "photos", "regional_infos", name: "photos_regional_info_id_fkey"
  add_foreign_key "places", "places", column: "parent_id", name: "places_parent_id_fkey"
  add_foreign_key "queries", "ancient_places", column: "ancient_finding_place_id", name: "queries_ancient_finding_place_id_fkey"
  add_foreign_key "queries", "museums", name: "queries_museum_id_fkey"
  add_foreign_key "queries", "places", column: "conservation_place_id", name: "queries_conservation_place_id_fkey"
  add_foreign_key "queries", "places", column: "finding_place_id", name: "queries_finding_place_id_fkey"
  add_foreign_key "regional_info_links", "regional_infos", name: "regional_info_links_regional_info_id_fkey"
  add_foreign_key "regional_infos", "places", name: "regional_info_place_id_fkey"
end
