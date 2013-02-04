class Contribution < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :contributor
  attr_accessible :amount, :contribution_type, :date, :candidate_id, :contributor_id

  def self.get_total_amount(filter)
    if filter == nil
      select_clause = "SELECT SUM(amount) as total from contributions"
    else
      select_clause = %Q{SELECT SUM(amount) as total FROM contributions
                         INNER JOIN candidates ON contributions.candidate_id = candidates.id
                         WHERE candidates.elected = 't'}
    end
    contributions = Contribution.connection.select_all(select_clause)
    #puts "Contribution.get_total_amount: #{contributions}"
    amount = contributions[0]
    amount["total"]
  end

  def self.get_candidate_subtotal(column_name, search, filter)
    if filter == nil
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          INNER JOIN candidates ON contributions.candidate_id = candidates.id
          WHERE candidates.#{column_name} LIKE '%#{search}%'}
    else
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          INNER JOIN candidates ON contributions.candidate_id = candidates.id
          WHERE candidates.elected = 't' AND candidates.#{column_name} LIKE '%#{search}%'}
    end
    contributions = Contribution.connection.select_all(select_clause)
    amount = contributions[0]
    amount["total"]
  end

  def self.get_contributor_subtotal(column_name, search, filter)
    if filter == nil
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          INNER JOIN contributors ON contributions.contributor_id = contributors.id
          WHERE contributors.#{column_name.to_s} LIKE '%#{search}%'}
    else
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          INNER JOIN contributors ON contributions.contributor_id = contributors.id
          JOIN candidates ON contributions.candidate_id = candidates.id
          WHERE candidates.elected = 't' AND contributors.#{column_name.to_s} LIKE '%#{search}%'}
    end
    contributions = Contribution.connection.select_all(select_clause)
    amount = contributions[0]
    amount["total"]
  end


  def self.get_candidate_total(id)
    contribution_totals = Contribution.connection.select_all(
     %Q{SELECT
          SUM(contributions.amount) as total,
          (SELECT COUNT(contributor_id)
             FROM contributions
             WHERE candidate_id = #{id.to_i}) as contributors,
         (SELECT SUM(amount)
            FROM contributions
            JOIN contributors ON contributors.id = contributions.contributor_id
            WHERE candidate_id = #{id.to_i} AND contributors.kind = 'Company' ) as company,
         (SELECT SUM(amount)
            FROM contributions
            JOIN contributors ON contributors.id = contributions.contributor_id
            WHERE candidate_id = #{id.to_i} AND contributors.kind = 'Person' ) as person
        FROM contributions
        WHERE candidate_id = '#{id.to_i}'} )
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

  def self.get_all_contributions filter
    if filter == nil
      select_clause =
     %Q{SELECT candidates.last as candidate, candidates.elected,
        contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id }
    else
      select_clause =
       %Q{SELECT candidates.last as candidate, candidates.elected,
          contributors.last as contributor,
          contributions.*
          FROM contributions
          INNER JOIN candidates ON contributions.candidate_id = candidates.id
          INNER JOIN contributors ON contributors.id = contributions.contributor_id
          where candidates.elected = 't' }
    end
    Contribution.connection.select_all(select_clause)
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

  def self.get_contributions_composition filter
    if filter == nil
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors JOIN contributions
       ON contributors.id = contributions.contributor_id
       GROUP BY kind }
    else
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors
       JOIN contributions ON contributors.id = contributions.contributor_id
       INNER JOIN candidates ON contributions.candidate_id = candidates.id
       WHERE candidates.elected = 't'
       GROUP BY kind }
    end
    Contribution.connection.select_all(select_clause)
  end

  def self.get_contributions_composition_by_selection(column_name, search, filter)
    if filter == nil
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors JOIN contributions
       ON contributors.id = contributions.contributor_id
       WHERE contributors.#{column_name} LIKE '%#{search}%'
       GROUP BY kind }
    else
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors
       JOIN contributions ON contributors.id = contributions.contributor_id
       INNER JOIN candidates ON contributions.candidate_id = candidates.id
       WHERE candidates.electe = 't' AND contributors.#{column_name} LIKE '%#{search}%'
       GROUP BY kind }
    end
    Contribution.connection.select_all(select_clause)
  end

  def self.get_candidate_contributions_composition_by_selection(column_name, search, filter)
    if filter == nil
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors
       JOIN contributions ON contributors.id = contributions.contributor_id
       JOIN candidates ON contributions.candidate_id = candidates.id
       WHERE candidates.#{column_name} LIKE '%#{search}%'
       GROUP BY kind }
    else
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors
       JOIN contributions ON contributors.id = contributions.contributor_id
       JOIN candidates ON contributions.candidate_id = candidates.id
       WHERE candidates.elected = 't' AND candidates.#{column_name} LIKE '%#{search}%'
       GROUP BY kind }
    end
    Contribution.connection.select_all(select_clause)
  end

  def self.find_contrib_mix_per_candidate( page, column_name, filter )
    # returns the candidate, # of contributors, $ company, $ person
    page_size = Candidate.get_page_size
    if page.nil?
      offset = 0
    else
      offset = page_size * (page.to_i - 1)
    end
    select_clause = %Q{
      SELECT candidates.id, candidates.last,
        (SELECT COUNT(contributor_id)
           FROM contributions
           WHERE candidate_id = candidates.id) as total,
        (SELECT SUM(amount)
           FROM contributions
           JOIN contributors ON contributors.id = contributions.contributor_id
           WHERE candidate_id = candidates.id AND contributors.kind = 'Company' ) as company,
        (SELECT SUM(amount)
           FROM contributions
           JOIN contributors ON contributors.id = contributions.contributor_id
           WHERE candidate_id = candidates.id AND contributors.kind = 'Person' ) as person
      FROM candidates
      }
    select_clause << %Q{ WHERE elected = 't' } if filter != nil
    select_clause << %Q{ ORDER BY candidates.#{column_name.to_s} } if !column_name.nil?
    select_clause << %Q{ LIMIT #{page_size} OFFSET #{offset}}

    Contribution.connection.select_all(select_clause)
  end

  def self.find_contrib_mix_per_candidate_range(search, page, column_name,filter)
    page_size = Candidate.get_page_size
    if page.nil?
      offset = 0
    else
      offset = page_size * (page.to_i - 1)
    end
    select_clause = %Q{
      SELECT candidates.id, candidates.last,
        (SELECT COUNT(contributor_id)
           FROM contributions
           WHERE candidate_id = candidates.id) as total,
        (SELECT SUM(amount)
           FROM contributions
           JOIN contributors ON contributors.id = contributions.contributor_id
           WHERE candidate_id = candidates.id AND contributors.kind = 'Company' ) as company,
        (SELECT SUM(amount)
           FROM contributions
           JOIN contributors ON contributors.id = contributions.contributor_id
           WHERE candidate_id = candidates.id AND contributors.kind = 'Person' ) as person
      FROM candidates
      WHERE candidates.#{column_name.to_s} LIKE '%#{search}%'
      }
    select_clause << %Q{ WHERE elected = 't' } if filter != nil
    select_clause << %Q{ ORDER BY candidates.#{column_name.to_s} LIMIT #{page_size} OFFSET #{offset}}

    Contribution.connection.select_all(select_clause)
  end

end
