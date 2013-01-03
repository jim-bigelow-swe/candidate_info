require 'spec_helper'

describe "contributors/index" do
  before(:each) do
    assign(:contributors, [
      stub_model(Contributor,
        :last => "Last",
        :suffix => "Suffix",
        :first => "First",
        :middle => "Middle",
        :mailing => "Mailing",
        :city => "City",
        :state => "State",
        :zip => "Zip"
      ),
      stub_model(Contributor,
        :last => "Last",
        :suffix => "Suffix",
        :first => "First",
        :middle => "Middle",
        :mailing => "Mailing",
        :city => "City",
        :state => "State",
        :zip => "Zip"
      )
    ])
  end

  it "renders a list of contributors" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Last".to_s, :count => 2
    assert_select "tr>td", :text => "Suffix".to_s, :count => 2
    assert_select "tr>td", :text => "First".to_s, :count => 2
    assert_select "tr>td", :text => "Middle".to_s, :count => 2
    assert_select "tr>td", :text => "Mailing".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "Zip".to_s, :count => 2
  end
end
