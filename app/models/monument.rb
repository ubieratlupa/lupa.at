class Monument < ActiveRecord::Base
  belongs_to :finding_place, class_name: "Place", optional: true
  belongs_to :conservation_place, class_name: "Place", optional: true
  belongs_to :ancient_finding_place, class_name: "AncientPlace", optional: true
  belongs_to :museum, optional: true
  belongs_to :parent_monument, class_name: "Monument", optional: true
  belongs_to :archaeology_author, class_name: "Author", optional: true
  belongs_to :epigraphy_author, class_name: "Author", optional: true
  belongs_to :architecture_author, class_name: "Author", optional: true
  
  has_many :photos
  has_many :child_monuments, class_name: "Monument", foreign_key: "parent_monument_id"
  
  default_scope { where(visible: true) }
  scope :found_in, ->(place) { 
    where("finding_place_id in (WITH RECURSIVE descendant_places AS (SELECT places.id FROM places WHERE id = ? UNION SELECT places.id FROM places JOIN descendant_places ON places.parent_id=descendant_places.id) SELECT id FROM descendant_places)", place).order(:id)
  }
  scope :conserved_in, ->(place) { 
    where("conservation_place_id in (WITH RECURSIVE descendant_places AS (SELECT places.id FROM places WHERE id = ? UNION SELECT places.id FROM places JOIN descendant_places ON places.parent_id=descendant_places.id) SELECT id FROM descendant_places)", place).order(:id)
  }
end
