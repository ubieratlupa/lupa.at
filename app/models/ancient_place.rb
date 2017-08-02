class AncientPlace < ActiveRecord::Base
  belongs_to :parent, class_name: "AncientPlace", optional: true
  has_many :children, class_name: "AncientPlace", foreign_key: "parent_id"
end
