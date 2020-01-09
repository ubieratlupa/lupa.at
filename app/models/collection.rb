class Collection < ApplicationRecord
  belongs_to :place
  has_many :monuments
end
