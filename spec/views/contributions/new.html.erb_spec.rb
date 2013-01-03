require 'spec_helper'

describe "contributions/new" do
  before(:each) do
    assign(:contribution, stub_model(Contribution,
      :candidate_id => nil,
      :contributor_id => nil,
      :amount => "9.99",
      :contribution_type => "MyString"
    ).as_new_record)
  end

  it "renders new contribution form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => contributions_path, :method => "post" do
      assert_select "input#contribution_candidate_id", :name => "contribution[candidate_id]"
      assert_select "input#contribution_contributor_id", :name => "contribution[contributor_id]"
      assert_select "input#contribution_amount", :name => "contribution[amount]"
      assert_select "input#contribution_contribution_type", :name => "contribution[contribution_type]"
    end
  end
end
