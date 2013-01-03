require 'spec_helper'

describe "contributors/new" do
  before(:each) do
    assign(:contributor, stub_model(Contributor,
      :last => "MyString",
      :suffix => "MyString",
      :first => "MyString",
      :middle => "MyString",
      :mailing => "MyString",
      :city => "MyString",
      :state => "MyString",
      :zip => "MyString"
    ).as_new_record)
  end

  it "renders new contributor form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => contributors_path, :method => "post" do
      assert_select "input#contributor_last", :name => "contributor[last]"
      assert_select "input#contributor_suffix", :name => "contributor[suffix]"
      assert_select "input#contributor_first", :name => "contributor[first]"
      assert_select "input#contributor_middle", :name => "contributor[middle]"
      assert_select "input#contributor_mailing", :name => "contributor[mailing]"
      assert_select "input#contributor_city", :name => "contributor[city]"
      assert_select "input#contributor_state", :name => "contributor[state]"
      assert_select "input#contributor_zip", :name => "contributor[zip]"
    end
  end
end
