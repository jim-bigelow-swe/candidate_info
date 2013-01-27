class Candidate < ActiveRecord::Base
  has_many :contributions
  has_many :contributiors, :through => :contributions
  attr_accessible :district, :elected, :first, :last, :middle, :office, :party, :suffix, :year

  self.per_page = 15

  def self.search(search, page, ordering)
  paginate :per_page => self.per_page, :page => page,
           :conditions => [ordering.to_s + ' like ?', "%#{search}%"], :order => ordering
  end

end
