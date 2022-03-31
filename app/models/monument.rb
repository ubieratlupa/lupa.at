class Monument < ActiveRecord::Base
  belongs_to :finding_place, class_name: "Place", optional: true
  belongs_to :conservation_place, class_name: "Place", optional: true
  belongs_to :regional_info, optional: true
  belongs_to :ancient_finding_place, class_name: "AncientPlace", optional: true
  belongs_to :museum, optional: true
  belongs_to :collection, optional: true
  belongs_to :parent_monument, class_name: "Monument", optional: true
  belongs_to :archaeology_author, class_name: "Author", optional: true
  belongs_to :epigraphy_author, class_name: "Author", optional: true
  belongs_to :architecture_author, class_name: "Author", optional: true
  
  has_many :photos
  has_many :child_monuments, class_name: "Monument", foreign_key: "parent_monument_id"
  
  has_and_belongs_to_many :publications
  
  default_scope { where(visible: true) }
  scope :found_in, ->(place) { 
    where("finding_place_id in (WITH RECURSIVE descendant_places AS (SELECT places.id FROM places WHERE id = ? UNION SELECT places.id FROM places JOIN descendant_places ON places.parent_id=descendant_places.id) SELECT id FROM descendant_places)", place).order(:id)
  }
  scope :conserved_in, ->(place) { 
    where("conservation_place_id in (WITH RECURSIVE descendant_places AS (SELECT places.id FROM places WHERE id = ? UNION SELECT places.id FROM places JOIN descendant_places ON places.parent_id=descendant_places.id) SELECT id FROM descendant_places)", place).order(:id)
  }
  
  def dating_years
    dating_years = ""
		if dating_from == dating_to
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
		elsif dating_from && dating_to
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
			dating_years += " - "
			dating_years += dating_to.abs.to_s
			dating_years += ' n. Chr.' if dating_to > 0
			dating_years += ' v. Chr.' if dating_to < 0
		elsif dating_from
			dating_years += "nach "
			dating_years += dating_from.abs.to_s
			dating_years += ' n. Chr.' if dating_from > 0
			dating_years += ' v. Chr.' if dating_from < 0
		elsif dating_to
			dating_years += "vor "
			dating_years += dating_to.abs.to_s
			dating_years += ' n. Chr.' if dating_to > 0
			dating_years += ' v. Chr.' if dating_to < 0
		end
    return dating_years
  end
  
  def self.recent_monuments_month
    date = ActiveRecord::Base.connection.execute("SELECT MIN(start_date) FROM neuzugänge").getvalue(0,0)
    if date
      return date
    end
    return Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
  end
  
  def self.recent_monuments(month)
    return Monument.where("id in (select distinct monument_id from photos where date_trunc('month',created) >= ?)", month).order("id desc")
  end
end
