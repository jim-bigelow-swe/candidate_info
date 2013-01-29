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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130129024833) do

  create_table "candidates", :force => true do |t|
    t.boolean  "elected",    :default => false
    t.date     "year"
    t.string   "last"
    t.string   "suffix"
    t.string   "first"
    t.string   "middle"
    t.string   "party"
    t.string   "district"
    t.string   "office"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "total",      :default => 0
  end

  create_table "contributions", :force => true do |t|
    t.integer  "candidate_id"
    t.integer  "contributor_id"
    t.date     "date"
    t.decimal  "amount"
    t.string   "contribution_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "contributions", ["candidate_id"], :name => "index_contributions_on_candidate_id"
  add_index "contributions", ["contributor_id"], :name => "index_contributions_on_contributor_id"

  create_table "contributors", :force => true do |t|
    t.string   "last"
    t.string   "suffix"
    t.string   "first"
    t.string   "middle"
    t.string   "mailing1"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "kind"
    t.string   "mailing2"
    t.string   "country"
    t.integer  "total",      :default => 0
  end

end
