class AddCountryToCandidateAddress < ActiveRecord::Migration
  def change
    add_column :contributors, :country, :string
  end
end
