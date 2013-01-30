class Contribution < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :contributor
  attr_accessible :amount, :contribution_type, :date, :candidate_id, :contributor_id

  def self.get_total_amount
    contributions = Contribution.connection.select_all("SELECT SUM(amount) as total from contributions")
    #puts "Contribution.get_total_amount: #{contributions}"
    amount = contributions[0]
    amount["total"]
  end

  def self.get_candidate_subtotal(column_name, search)
    contributions = Contribution.connection.select_all(
     %Q{SELECT SUM(amount) as total FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        WHERE candidates.#{column_name} LIKE '%#{search}%'} )
    amount = contributions[0]
    amount["total"]
  end

  def self.get_contributor_subtotal(column_name, search)
    contributions =
      Contribution.connection.select_all(
     %Q{SELECT SUM(amount) as total FROM contributions
        INNER JOIN contributors ON contributions.contributor_id = contributors.id
        WHERE contributors.#{column_name.to_s} LIKE '%#{search}%'} )
    amount = contributions[0]
    amount["total"]
  end


  def self.get_candidate_total(id)
    contribution_totals = Contribution.connection.select_all(
     %Q{SELECT SUM(contributions.amount) as contribution_total
        FROM contributions
        WHERE candidate_id = '#{id.to_i}'} )
    (contribution_totals[0]["contribution_total"])
  end

  def self.get_candidate_contributions(id)
    Contribution.connection.select_all(
     %Q{SELECT contributors.kind as kind, contributors.last as contributor, contributions.*
        FROM contributions
        INNER JOIN contributors ON contributions.contributor_id = contributors.id
        WHERE contributions.candidate_id = '#{id.to_i}' } )
  end

  def self.get_contributor_total(id)
    contribution_totals = Contribution.connection.select_all(
     %Q{SELECT SUM(contributions.amount) as contribution_total
        FROM contributions
        WHERE contributor_id = '#{id.to_i}'} )
    contribution_totals[0]["contribution_total"]
  end

  def self.get_contributor_contributions(id)
    Contribution.connection.select_all(
     %Q{SELECT candidates.last as candidate, contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        WHERE contributions.contributor_id = '#{id.to_i}' } )
  end

  def self.get_all_contributions
    Contribution.connection.select_all(
     %Q{SELECT candidates.last as candidate, candidates.elected,
        contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id })
  end

  def self.get_contribution_details(id)
    data_set = Contribution.connection.select_all(
     %Q{SELECT candidates.last as candidate, contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id
        WHERE contributions.id = '#{id}'} )
    data_set[0]
  end

end
