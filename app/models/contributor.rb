class Contributor < ActiveRecord::Base
  attr_accessible :kind, :city, :first, :last, :mailing1, :mailing2, :middle, :state, :suffix, :zip, :country
  has_many :contributions
  has_many :candidate, :through => :contributions
end
