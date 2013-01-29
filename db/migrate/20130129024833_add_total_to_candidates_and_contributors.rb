class AddTotalToCandidatesAndContributors < ActiveRecord::Migration
  def change
    add_column :candidates,   :total, :integer, :default => 0
    add_column :contributors, :total, :integer, :default => 0
  end
end
