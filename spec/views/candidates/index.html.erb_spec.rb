require 'spec_helper'

describe "candidates/index" do
  before(:each) do
    assign(:candidates, [
      stub_model(Candidate,
        :elected => false,
        :last => "Last",
        :suffix => "Suffix",
        :first => "First",
        :middle => "Middle",
        :party => "Party",
        :district => "District",
        :office => "Office"
      ),
      stub_model(Candidate,
        :elected => false,
        :last => "Last",
        :suffix => "Suffix",
        :first => "First",
        :middle => "Middle",
        :party => "Party",
        :district => "District",
        :office => "Office"
      )
    ])
  end

  it "renders a list of candidates" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Last".to_s, :count => 2
    assert_select "tr>td", :text => "Suffix".to_s, :count => 2
    assert_select "tr>td", :text => "First".to_s, :count => 2
    assert_select "tr>td", :text => "Middle".to_s, :count => 2
    assert_select "tr>td", :text => "Party".to_s, :count => 2
    assert_select "tr>td", :text => "District".to_s, :count => 2
    assert_select "tr>td", :text => "Office".to_s, :count => 2
  end
end
