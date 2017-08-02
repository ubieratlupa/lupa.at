class Place < ActiveRecord::Base
  belongs_to :parent, class_name: "Place"
  has_many :children, class_name: "Place", foreign_key: "parent_id"
  has_many :museums
  
  def hierarchy
      places = []
      place = self
      while place
        places.unshift(place)
        place = place.parent
      end
      places
  end
  
  def children
    Place.where(parent: self)
  end
end
