class Contributor < ActiveRecord::Base
  attr_accessible :kind, :city, :first, :last, :mailing1, :mailing2, :middle, :state, :suffix, :zip, :country
  has_many :contributions
  has_many :candidate, :through => :contributions

  self.per_page = 15

  def self.search(search, page, ordering)
    paginate :per_page => self.per_page,
      :page => page,
      :conditions => [ordering.to_s + ' like ?', "%#{search}%"],
      :order => ordering
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

  def self.get_contributor_makeup_by_selection(column_name, search)
    Contributor.connection.select_all(%Q{
         SELECT kind, COUNT(*) as number
         FROM contributors
         WHERE contributors.#{column_name} LIKE '%#{search}%'
         GROUP BY kind })
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
