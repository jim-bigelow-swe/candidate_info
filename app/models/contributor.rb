class Contributor < ActiveRecord::Base
  attr_accessible :kind, :city, :first, :last, :mailing1, :mailing2, :middle, :state, :suffix, :zip, :country
  has_many :contributions
  has_many :candidate, :through => :contributions

  self.per_page = 15

  def self.search(search, page, ordering, filter)
    expression = ordering.to_s + ' LIKE ?'
    expression = (%Q{contributors.id IN
                     (SELECT contributions.contributor_id
                      FROM contributions
                      JOIN candidates on contributions.candidate_id = candidates.id
                      WHERE candidates.elected = 't' ) AND } + expression) if filter != nil
    paginate :per_page => self.per_page, :page => page,
    :conditions => [expression, "%#{search}%"],
    :order => ordering
  end

  def self.page(page, ordering, filter)
    if filter == nil
      paginate :per_page => self.per_page, :page => page, :order => ordering
    else
      paginate :per_page => self.per_page, :page => page,
        :order => ordering,
        :conditions => %Q{contributors.id IN
                          (SELECT contributions.contributor_id
                           FROM contributions
                           JOIN candidates on contributions.candidate_id = candidates.id
                           WHERE candidates.elected = 't' )}
    end
  end

  def self.get_contributor_makeup(filter)
    if filter == nil
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         GROUP BY kind }
    else
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE candidates.elected = 't'
         GROUP BY kind }
    end
    Contributor.connection.select_all(select_clause)
  end

  def self.get_contributor_makeup_by_selection(column_name, search, filter)
    if filter == nil
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         WHERE contributors.#{column_name} LIKE '%#{search}%'
         GROUP BY kind }
    else
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE candidates.elected = 't'
         AND contributors.#{column_name} LIKE '%#{search}%'
         GROUP BY kind }
    end
    Contributor.connection.select_all(select_clause)
  end

  def self.get_contribution_contributor_makeup_by_selection(column_name, search, filter)
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
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE contributions.#{column_name} #{operators} #{search}
         GROUP BY kind }
    else
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE candidates.elected = 't' AND contributions.#{column_name} #{operator} #{search}
         GROUP BY kind }
    end
    Contributor.connection.select_all(select_clause)
  end

  def self.get_candidate_contributor_makeup_by_selection(column_name, search, filter)
    if filter == nil
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE candidates.#{column_name} LIKE '%#{search}%'
         GROUP BY kind }
    else
      select_clause = %Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         JOIN contributions ON contributors.id = contributions.contributor_id
         JOIN candidates ON contributions.candidate_id = candidates.id
         WHERE candidates.elected = 't' AND candidates.#{column_name} LIKE '%#{search}%'
         GROUP BY kind }
    end
    Contributor.connection.select_all(select_clause)
  end

end
