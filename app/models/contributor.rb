class Contributor < ActiveRecord::Base
  attr_accessible :kind, :city, :first, :last, :mailing1, :mailing2, :middle, :state, :suffix, :zip, :country
  has_many :contributions
  has_many :candidate, :through => :contributions

  self.per_page = 15

  def self.search(search, page, ordering)
  paginate :per_page => self.per_page, :page => page,
    :conditions => [ordering.to_s + ' like ?', "%#{search}%"],
    :order => ordering
  end

end
