class Contribution < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :contributor
  attr_accessible :amount, :contribution_type, :date, :candidate_id, :contributor_id
end
