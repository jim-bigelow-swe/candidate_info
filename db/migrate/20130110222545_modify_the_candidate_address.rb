class ModifyTheCandidateAddress < ActiveRecord::Migration
  def up
    rename_column :contributors, :mailing, :mailing1
    add_column :contributors, :mailing2, :string
  end

  def down
  end
end
