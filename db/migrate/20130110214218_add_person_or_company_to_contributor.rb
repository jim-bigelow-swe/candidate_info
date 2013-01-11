class AddPersonOrCompanyToContributor < ActiveRecord::Migration
  def change
    add_column :contributors, "kind", :string
  end
end
