class Place < ActiveRecord::Base
  belongs_to :parent, class_name: "Place"
end
