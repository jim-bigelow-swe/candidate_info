require 'spec_helper'

describe "candidates/show" do
  before(:each) do
    @candidate = assign(:candidate, stub_model(Candidate,
      :elected => false,
      :last => "Last",
      :suffix => "Suffix",
      :first => "First",
      :middle => "Middle",
      :party => "Party",
      :district => "District",
      :office => "Office"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    rendered.should match(/Last/)
    rendered.should match(/Suffix/)
    rendered.should match(/First/)
    rendered.should match(/Middle/)
    rendered.should match(/Party/)
    rendered.should match(/District/)
    rendered.should match(/Office/)
  end
end
