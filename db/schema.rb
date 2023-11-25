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

ActiveRecord::Schema[7.0].define(version: 2022_10_18_122438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "dating_phase", ["Antoninisch", "Antoninisch-Severisch", "Augusteisch", "Claudisch", "Constantinisch", "Domitianisch", "Flavisch", "Frühchristlich", "Frühmittelalterlich", "Gallienisch", "Griechisch-Spätklassisch", "Hadrianisch", "Hellenistisch", "Iulisch-Claudisch", "Iustinianisch", "Neronisch", "Prähistorisch", "Republikanisch", "Severisch", "Severisch-Soldatenkaiser", "Soldatenkaiser", "Spätantik", "Spätrepublikanisch", "Tetrarchisch", "Tiberisch", "Traianisch", "Traianisch-Hadrianisch", "Traianisch-Soldatenkaiser", "Vespasianisch", "Vorrömisch", "Griechische Klassik", "Archaik", "Griechische Archaik"]
  create_enum "inscription_type", ["Bauinschrift", "Besitzerinschrift", "Defixio", "Ehreninschrift", "Gesetz / Juridischer Text", "Grabinschrift", "Graffito", "Grenzstein", "Hospitiumvertrag", "Meilensteininschrift", "Militärdiplom", "Patronatsvertrag", "Sitzinschrift", "Stempel", "Votiv / Kultinschrift", "Einweihung", "Hermeninschrift", "(?)", "Kommemorativinschrift", "mittelalterlich", "neuzeitlich", "Stifterinschrift"]
  create_enum "material", ["Stein", "Alabaster", "Andesit", "Basalt", "Granit", "Kalkstein", "Konglomerat", "Marmor", "Porphyr", "Sandstein", "Schmuckstein", "Trachit", "Tuffstein", "Mosaik", "Wandmalerei", "Blei", "Bronze", "Eisen", "Holz", "Ton", "Lavez"]
  create_enum "monument_type", ["(?)", "Architektur", "Brunnen", "Brücke", "Büste oder Statue", "Felsengrab", "Forum", "Grabaedicula", "Grabaedicula (?)", "Grabaedicula (?) Grabbezirk (?)", "Grabaedicula (?) Tumulus (?)", "Grabbau", "Grabbezirk", "Grabbezirk (?)", "Grabkammer", "Heiligtum / Tempel", "Jupiter-Säule", "Kirche", "Militärbau", "Mobiliar", "Nymphaeum", "Palastanlage", "Pfeilergrabmal", "Pfeilergrabmal (?)", "Propylon", "Stadttor / Bogen", "Statue (?)", "Statue / Statuette", "Statuenbasis", "Steinbruch / Bergwerk", "Theater / Amphitheater", "Triumphbogen / Ehrenbogen", "Tropaion / Tropaeum", "Tumulus", "Tumulus (?)"]
  create_enum "object_type", ["(?)", "Akroter", "Altar", "Altar / Basis", "Altarbekrönung", "Antefix", "Architrav", "Arkade", "Aschenkiste / Urne", "Bank", "Basis ", "Bauquader", "Bleibarren", "Brunnenfassung", "Büste", "Cippus", "Ciste", "Dach", "Decke", "Dromos-Verkleidung", "Eckblock", "Felsinschrift / Felszeichnung / Felsrelief", "Firstbalken", "Fries", "Gefäß", "Gesims", "Gewicht / Hohlmaß", "Giebel", "Grabaltar ", "Grabbau", "Grabeinfassung", "Grabmedaillon", "Grabpfeiler", "Grabstein", "Herme", "Horologion", "Inschrift", "Inschrift zwischen Seitenfeldern", "Jupiter-Säule", "Kameo / Gemme", "Kapitell", "Konsole", "Kopf", "Körpervotiv", "Lorica", "Löwe", "Löwenaufsatz", "Maske", "Meilenstein", "Militärdiplom", "Mosaik", "Oscillum", "Pfeiler", "Pilaster", "Pinienzapfen", "Platte", "Platte mit Ritzzeichnung", "Porträtnische", "Porträtnische mit Inschrift", "Pyramidenstumpf", "Pyramidenstumpf mit Löwen", "Relief", "rundplastische Tierskulptur", "Sarkophag", "Seitenwange einer Grabaedicula", "Sonnenuhr", "Sphinx", "Statue", "Statuenbasis", "Statuette", "Statuette mit Votivinschrift", "Stele", "Säule", "Säulenbasis", "Titulus", "Tondo", "Tropaion (Tropaeum)", "Volute", "Votivaedicula", "Votivaltar", "Votivrelief ", "Wand eines Grabbaus", "Wand mit Pilastern/Halbsäulen", "Wandmalerei", "Wasserspeier", "Ziegel", "Felsrelief/Felsinschrift", "gerahmtes Schriftfeld", "Mobiliar"]

  create_table "ancient_places", id: :integer, default: -> { "next_id('vocabulary'::text, 'ancient_places'::text)" }, force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.float "long"
    t.float "lat"
    t.text "full_name"
  end

  create_table "authors", id: :integer, default: -> { "next_id('vocabulary'::text, 'authors'::text)" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.text "institution"
    t.text "comment"
    t.text "email"
    t.boolean "visible", default: true, null: false
    t.text "credit_name", comment: "Dieser Name erscheint am Datenblatt und bei den Fotos (falls leer, wird first_name + last_name angezeigt)"
  end

  create_table "collections", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "summary"
    t.bigint "place_id"
    t.string "link_1"
    t.string "link_2"
    t.string "link_3"
    t.index ["place_id"], name: "index_collections_on_place_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "monument_id"
    t.text "name"
    t.text "email"
    t.text "comment"
    t.datetime "created", precision: nil
  end

  create_table "copyrights", id: :integer, default: -> { "next_id('vocabulary'::text, 'copyrights'::text)" }, force: :cascade do |t|
    t.string "copyright"
    t.boolean "publication_permission_required", default: true, null: false
  end

  create_table "dating_phases_time_span", id: false, force: :cascade do |t|
    t.enum "phase_name", enum_type: "dating_phase"
    t.integer "phase_from"
    t.integer "phase_to"
  end

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

  create_table "monuments", id: :integer, default: -> { "next_monument_id()" }, force: :cascade do |t|
    t.string "title", limit: 255
    t.text "catalog_text"
    t.string "comment", limit: 255
    t.enum "object_type", enum_type: "object_type"
    t.enum "monument_type", enum_type: "monument_type"
    t.integer "finding_place_id"
    t.string "finding_place_comment"
    t.text "finding_comment"
    t.integer "ancient_finding_place_id"
    t.integer "conservation_place_id"
    t.string "conservation_place_comment"
    t.string "conservation_comment", limit: 255
    t.string "conservation_state", limit: 255
    t.integer "regional_info_id"
    t.integer "museum_id"
    t.string "museum_inventory_number", limit: 100
    t.text "iconography"
    t.enum "inscription_type", enum_type: "inscription_type"
    t.text "inscription"
    t.text "inscription_comment"
    t.text "inscription_variants"
    t.string "inscription_letter_size", limit: 100
    t.text "inscription_paleography"
    t.text "inscription_translation"
    t.string "inscription_name_donor", limit: 255
    t.string "inscription_function", limit: 255
    t.string "inscription_formula", limit: 255
    t.enum "dating_phase", enum_type: "dating_phase"
    t.integer "dating_from"
    t.integer "dating_to"
    t.string "dating_comment", limit: 255
    t.integer "parent_monument_id"
    t.string "width", limit: 20
    t.string "height", limit: 20
    t.string "depth", limit: 20
    t.text "literature"
    t.text "literature_online"
    t.enum "material", enum_type: "material"
    t.text "material_comment"
    t.string "material_sri", limit: 255
    t.text "material_local_name"
    t.text "material_provenance"
    t.text "material_arguments"
    t.string "material_analysis_author", limit: 255
    t.integer "archaeology_author_id"
    t.integer "epigraphy_author_id"
    t.integer "architecture_author_id"
    t.datetime "created", precision: nil, default: -> { "now()" }
    t.datetime "modified", precision: nil
    t.boolean "visible", default: false, null: false
    t.text "column52"
    t.bigint "collection_id"
    t.decimal "finding_lat"
    t.decimal "finding_long"
    t.decimal "conservation_lat"
    t.decimal "conservation_long"
    t.index ["collection_id"], name: "index_monuments_on_collection_id"
    t.index ["conservation_place_id"], name: "monuments_conservation_place_id_idx"
    t.index ["finding_place_id"], name: "monuments_finding_place_id_idx"
    t.index ["modified", "id"], name: "monuments_reverse_update_idx", order: { modified: "DESC NULLS LAST" }
  end

  create_table "museums", id: :integer, default: -> { "next_id('vocabulary'::text, 'museums'::text)" }, force: :cascade do |t|
    t.string "name", limit: 100
    t.integer "place_id", null: false
    t.text "short_name"
    t.text "description"
    t.text "website"
    t.index ["short_name"], name: "museums_short_name_key", unique: true
    t.check_constraint "short_name ~ '/^[-\\w_]+$/'::text", name: "Numbers, Letters, Underscore, Dash"
    t.check_constraint "website ~ '^https?://'::text", name: "Begins with http"
  end

  create_table "neuzugänge", id: false, force: :cascade do |t|
    t.date "start_date"
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
    t.datetime "created", precision: nil, default: -> { "now()" }
    t.datetime "modified", precision: nil
    t.index ["monument_id"], name: "photos_monument_id_idx"
  end

  create_table "places", id: :integer, default: -> { "next_id('vocabulary'::text, 'places'::text)" }, force: :cascade do |t|
    t.text "name"
    t.text "name_en"
    t.text "place_type"
    t.text "place_type_en"
    t.integer "parent_id"
    t.decimal "lat"
    t.decimal "long"
    t.text "full_name"
    t.datetime "created", precision: nil
    t.datetime "modified", precision: nil
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "authors"
    t.integer "year"
    t.text "citation"
    t.text "abstract"
    t.text "link"
    t.text "doi"
    t.text "pdf_link"
    t.text "monument_ids"
    t.timestamptz "created", default: -> { "now()" }
    t.timestamptz "modified"
  end

  create_table "queries", id: :integer, default: -> { "((('x'::text || encode(gen_random_bytes(4), 'hex'::text)))::bit(31))::integer" }, force: :cascade do |t|
    t.timestamptz "created", default: -> { "now()" }, null: false
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
    t.text "object_type"
    t.enum "inscription_type", enum_type: "inscription_type"
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
    t.datetime "created", precision: nil, default: -> { "now()" }
    t.datetime "modified", precision: nil
  end

  add_foreign_key "ancient_places", "ancient_places", column: "parent_id", name: "ancient_places_parent_id_fkey"
  add_foreign_key "collections", "places"
  add_foreign_key "comments", "monuments", name: "comments_monument_id_fkey"
  add_foreign_key "monuments", "ancient_places", column: "ancient_finding_place_id", name: "monuments_ancient_finding_place_id_fkey"
  add_foreign_key "monuments", "authors", column: "archaeology_author_id", name: "monuments_archaeology_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "authors", column: "architecture_author_id", name: "monuments_architecture_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "authors", column: "epigraphy_author_id", name: "monuments_epigraphy_author_id_fkey", on_update: :cascade
  add_foreign_key "monuments", "collections"
  add_foreign_key "monuments", "monuments", column: "parent_monument_id", name: "monuments_related_monument_id_fkey", on_update: :cascade
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
