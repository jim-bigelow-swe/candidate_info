
Given /^the following contribution records exist:$/ do |table|

  Contribution.delete_all(1)
  Candidate.delete_all(1)
  Contributor.delete_all(1)
  @candidates = Hash.new
  table.hashes.each do |record|

    if @candidates[record[:cand_last].to_s].nil?

      @candidate = Candidate.create!(:year     => record[:election_year],
                                     :last     => record[:cand_last],
                                     :suffix   => record[:cand_suf],
                                     :first    => record[:cand_first],
                                     :middle   => record[:cand_mid],
                                     :party    => record[:cand_party],
                                     :district => record[:cand_district],
                                     :office   => record[:cand_office]
                                     )
      @candidates[@candidate.last] = @candidate.id
      @candidate_id = @candidate.id
    else
      @candidate_id = @candidates[record[:cand_last].to_s]
    end


    @contributor = Contributor.create!(
      :last    => record[:contr_last],
      :suffix  => record[:contr_suf],
      :first   => record[:contr_first],
      :middle  => record[:contr_mid],
      :mailing => record[:contr_mailing],
      :city    => record[:contr_city],
      :state   => record[:contr_st],
      :zip     => record[:contr_zip]
    )

    @contribution = Contribution.create!(
      :date              => record[:contr_date],
      :amount            => record[:contr_amount].tr('",', ''),
      :contribution_type => record[:contr_type],
      :candidate_id      => @candidate_id,
      :contributor_id    => @contributor.id
    )
    debugger
  end
end


Given /^that I have created a contribution record$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a contribution record$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see Candidate "(.*?)"$/ do |arg1|
  page.should have_content(arg1)
end

Then /^I debug$/ do
  debugger
end
