require 'spec_helper'

describe "contributors/show" do
  before(:each) do
    @contributor = assign(:contributor, stub_model(Contributor,
      :last => "Last",
      :suffix => "Suffix",
      :first => "First",
      :middle => "Middle",
      :mailing => "Mailing",
      :city => "City",
      :state => "State",
      :zip => "Zip"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Last/)
    rendered.should match(/Suffix/)
    rendered.should match(/First/)
    rendered.should match(/Middle/)
    rendered.should match(/Mailing/)
    rendered.should match(/City/)
    rendered.should match(/State/)
    rendered.should match(/Zip/)
  end
end
