class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.belongs_to :candidate
      t.belongs_to :contributor
      t.date :date
      t.decimal :amount
      t.string :contribution_type

      t.timestamps
    end
    add_index :contributions, :candidate_id
    add_index :contributions, :contributor_id
  end
end
