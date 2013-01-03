class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :last
      t.string :suffix
      t.string :first
      t.string :middle
      t.string :mailing
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
  end
end
