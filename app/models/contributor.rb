class Contributor < ActiveRecord::Base
  attr_accessible :city, :first, :last, :mailing, :middle, :state, :suffix, :zip
  has_many :contributions
  has_many :candidate, :through => :contributions
end
