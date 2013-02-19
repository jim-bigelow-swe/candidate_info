class Contribution < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :contributor
  attr_accessible :amount, :contribution_type, :date, :candidate_id, :contributor_id

  self.per_page = 15
  def self.get_page_size
    per_page
  end

  def self.search(search, page, ordering, filter)

    operator = %Q{LIKE}
    if ordering == :amount
      value = search.to_i * 100  # get the number into the range of stored values
      search = value.to_s
      operator = ">="
    else
      operator = %Q{LIKE}
      search = %Q{%#{search}%}
    end

    expression = ordering.to_s + %Q{ #{operator} ?}

    puts expression

    expression = (%Q{contributions.candidate_id IN
                     (SELECT candidates.id
                      FROM candidates
                      WHERE candidates.elected = 't' AND
                      candidates.id = contributions.candidate_id) AND } + expression) if filter != nil
    paginate :per_page => self.per_page, :page => page,
    :conditions => [expression, search],
    :order => ordering
  end

  def self.page(page, ordering, filter)

    if filter == nil
      paginate :per_page => self.per_page, :page => page, :order => ordering
    else
      paginate :per_page => self.per_page, :page => page,
        :order => ordering,
        :conditions => %Q{contributions.candidate_id IN
                          (SELECT candidates.id
                           FROM candidates
                           WHERE candidates.elected = 't' AND
                           candidates.id = contributions.candidate_id)}
    end
  end


  def self.get_total_amount(filter)
    if filter == nil
      select_clause = %Q{SELECT SUM(amount) AS total FROM contributions}
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

  def self.get_contribution_subtotal(column_name, search, filter)
    operator = "LIKE"
    if column_name == :amount
      value = search.to_i * 100  # get the number into the range of stored values
      search = value.to_s
      operator = ">="
    else
      search = %Q{'%#{search}%'}
    end

    if filter == nil
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          WHERE contributions.#{column_name} #{operator} #{search}}
    else
      select_clause =
       %Q{SELECT SUM(amount) as total FROM contributions
          INNER JOIN candidates ON contributions.candidate_id = candidates.id
          WHERE candidates.elected = 't' AND contributions.#{column_name} #{operator} #{search}}
    end
    contributions = Contribution.connection.select_all(select_clause)
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
    select_clause =
     %Q{SELECT candidates.last as candidate, candidates.elected,
        contributors.last as contributor,
        contributions.*
        FROM contributions
        INNER JOIN candidates ON contributions.candidate_id = candidates.id
        INNER JOIN contributors ON contributors.id = contributions.contributor_id }
    select_clause << %{WHERE candidates.elected = 't' } if !filter.nil?
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

  def self.get_contribution_composition_by_selection(column_name, search, filter)
    operator = "LIKE"
    if column_name == :amount
      value = search.to_i * 100  # get the number into the range of stored values
      search = value.to_s
      operator = ">="
    else
      search = %Q{'%#{search}%'}
    end

    if filter == nil
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors JOIN contributions
       ON contributors.id = contributions.contributor_id
       WHERE contributions.#{column_name} #{operator} #{search}
       GROUP BY kind }
    else
      select_clause = %Q{
       SELECT kind, COUNT(*) as number, SUM(amount) as total
       FROM contributors
       JOIN contributions ON contributors.id = contributions.contributor_id
       INNER JOIN candidates ON contributions.candidate_id = candidates.id
       WHERE candidates.elected = 't' AND contributions.#{column_name} #{operator} #{search}
       GROUP BY kind }
    end
    Contribution.connection.select_all(select_clause)
  end

  def self.get_contributor_contributions_composition_by_selection(column_name, search, filter)
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
       WHERE candidates.elected = 't' AND contributors.#{column_name} LIKE '%#{search}%'
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

  def self.find_contrib_mix_per_candidate(filter )
    # returns the candidate, # of contributors, $ company, $ person
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

    Contribution.connection.select_all(select_clause)
  end

end
