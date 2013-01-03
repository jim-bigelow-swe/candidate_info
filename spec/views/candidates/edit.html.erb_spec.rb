require 'spec_helper'

describe "candidates/edit" do
  before(:each) do
    @candidate = assign(:candidate, stub_model(Candidate,
      :elected => false,
      :last => "MyString",
      :suffix => "MyString",
      :first => "MyString",
      :middle => "MyString",
      :party => "MyString",
      :district => "MyString",
      :office => "MyString"
    ))
  end

  it "renders the edit candidate form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => candidates_path(@candidate), :method => "post" do
      assert_select "input#candidate_elected", :name => "candidate[elected]"
      assert_select "input#candidate_last", :name => "candidate[last]"
      assert_select "input#candidate_suffix", :name => "candidate[suffix]"
      assert_select "input#candidate_first", :name => "candidate[first]"
      assert_select "input#candidate_middle", :name => "candidate[middle]"
      assert_select "input#candidate_party", :name => "candidate[party]"
      assert_select "input#candidate_district", :name => "candidate[district]"
      assert_select "input#candidate_office", :name => "candidate[office]"
    end
  end
end
