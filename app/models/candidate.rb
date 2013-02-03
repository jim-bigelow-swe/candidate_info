class Candidate < ActiveRecord::Base
  has_many :contributions
  has_many :contributiors, :through => :contributions
  attr_accessible :district, :elected, :first, :last, :middle, :office, :party, :suffix, :year

  self.per_page = 15
  def self.get_page_size
    per_page
  end

  def self.search(search, page, ordering, filter)
    expression = ordering.to_s + ' like ?'
    expression = (%Q{elected = 't' and } + expression) if filter != nil
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
        :conditions => %Q{elected = 't'}
    end
  end


end
