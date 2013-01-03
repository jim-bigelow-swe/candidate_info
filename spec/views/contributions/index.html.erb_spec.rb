require 'spec_helper'

describe "contributions/index" do
  before(:each) do
    assign(:contributions, [
      stub_model(Contribution,
        :candidate_id => nil,
        :contributor_id => nil,
        :amount => "9.99",
        :contribution_type => "Contribution Type"
      ),
      stub_model(Contribution,
        :candidate_id => nil,
        :contributor_id => nil,
        :amount => "9.99",
        :contribution_type => "Contribution Type"
      )
    ])
  end

  it "renders a list of contributions" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Contribution Type".to_s, :count => 2
  end
end
