class AncientPlace < ActiveRecord::Base
  belongs_to :parent, class_name: "AncientPlace", optional: true
end
