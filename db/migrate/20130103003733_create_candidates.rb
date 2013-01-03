class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.boolean :elected, :default => false
      t.date :year
      t.string :last
      t.string :suffix
      t.string :first
      t.string :middle
      t.string :party
      t.string :district
      t.string :office

      t.timestamps
    end
  end
end
