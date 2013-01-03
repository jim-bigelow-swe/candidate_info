class Candidate < ActiveRecord::Base
  has_many :contributions
  has_many :contributiors, :through => :contributions
  attr_accessible :district, :elected, :first, :last, :middle, :office, :party, :suffix, :year
end
