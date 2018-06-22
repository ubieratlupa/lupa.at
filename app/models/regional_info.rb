class RegionalInfo < ActiveRecord::Base
  has_many :photos
  has_many :monuments
end
