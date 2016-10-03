class Museum < ActiveRecord::Base
  belongs_to :place
  has_many :monuments
end
