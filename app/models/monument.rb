class Monument < ActiveRecord::Base
  belongs_to :finding_place, class_name: "Place", optional: true
  belongs_to :conservation_place, class_name: "Place", optional: true
  belongs_to :ancient_finding_place, class_name: "AncientPlace", optional: true
  belongs_to :museum, optional: true
  
  has_many :photos
  
  default_scope { order(:id) }
end
