class Publication < ApplicationRecord
  has_and_belongs_to_many :monuments
end
