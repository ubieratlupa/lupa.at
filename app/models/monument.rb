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
    datestr = ActiveRecord::Base.connection.execute("SELECT MIN(start_date) FROM neuzugänge").getvalue(0,0)
    if datestr
      return Date.parse(datestr)
    end
    return Photo.select("date_trunc('month',max(created)) AS created").where("monument_id not in (select id from monuments where not visible)")[0].created
  end
  
  def self.recent_monuments(month)
    return Monument.where("id in (select distinct monument_id from photos where created >= ?)", month).order("id desc")
  end

  

  # conversion to EDM format to support OAI-PHM export in EDMW
  # https://wissen.kulturpool.at/books/europeana-data-model-edm/page/kurzreferenz-edm-pflichtfelder
  # https://europeana.atlassian.net/wiki/spaces/EF/pages/2106294284/edm+ProvidedCHO
  def to_oai_edm
    lupa_root_url = "https://lupa.at"
    monument_url = lupa_root_url + "/" + id.to_s
    providedCHO = monument_url + "#ProvidedCHO"
    aggregation = monument_url + "#Aggreagation"
    
    # get exportable photos and 3d model
    exportable_photos = photos.where(copyright_id: [1, 11, 91])
    file_path_3dm = Rails.root.join("public", "3dm", id.to_s + ".nxz")
    model3d_url = lupa_root_url + "/3dm/" + id.to_s + ".nxz"
    has_3d_model = File.exist?(file_path_3dm)

    
    # verify if this record may be exported. otherwise, return nil
    return nil unless has_3d_model || exportable_photos.exists?
           
    # Create a new XML builder object
    xml = ::Builder::XmlMarkup.new

    # Define the root element and namespaces for EDM
    xml.tag!("rdf:RDF", 
      'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
      'xmlns:dcterms' => "http://purl.org/dc/terms/",
      'xmlns:edm' => "http://www.europeana.eu/schemas/edm/",
      'xmlns:ore' => "http://www.openarchives.org/ore/terms/",
      'xmlns:rdf' => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      ) do
     
      # ProvidedCHO: represents a cultural heritage object in EDM
      #----------------------------------------------------------------------
      xml.tag!("edm:ProvidedCHO", "rdf:about" => providedCHO) do
      #--- REQUIRED fields for EDM
        xml.tag!("dc:title", title)                      # (0..n) Titel oder Name des Objekts
        # (0..n) Beschreibung des Objekts
        xml.tag!("dc:description", iconography) if iconography
        xml.tag!("dc:description", inscription) if inscription
        xml.tag!("dc:description", inscription_translation) if inscription_translation
        xml.tag!("dc:description", inscription_comment) if inscription_comment
        xml.tag!("dc:description", conservation_state) if conservation_state
        xml.tag!("dc:description", comment) if comment
        # at least one of the above two has to be provided!
        xml.tag!("dc:identifier", id)                    # (0..n) Identifikator des Objekts (eindeutig innerhalb der Institution)
        #xml.tag!("dc:language", "...")          "      # (0..n) Sprache des Texts auf dem Objekt, Pflichtfeld, wenn Medientyp «edm:type» TEXT ist, Angabe als ISO-639-1 oder 639-3
        xml.tag!("edm:type", has_3d_model ? "3D" : "IMAGE")         # (1..1) Medienkategorie des digitalen Objekts (Einzig mögliche Werte: IMAGE, TEXT, VIDEO, AUDIO, 3D)
        # at least one of the following 4 fields has to be provided!
        #xml.tag!("dc:subject", "...")                   # (0..n) Thema, das das Kulturgut darstellt oder behandelt
        xml.tag!("dc:subject", "Archaeological artifact", "rdf:resource" => "http://www.wikidata.org/entity/Q220659")
        xml.tag!("dc:subject", "Roman antiquities", "rdf:resource" => "http://id.loc.gov/authorities/subjects/sh85115119")
        xml.tag!("dc:subject", "Stones (worked rock)", "rdf:resource" => "http://vocab.getty.edu/aat/300011176")
        xml.tag!("dc:subject", "Stone carving", "rdf:resource" => "http://id.loc.gov/authorities/subjects/sh85128775")
        xml.tag!("dc:type", object_type)            # (0..n) Begriff zur Beschreibung der spezifischen Art des Objekts (Angabe durch kontrolliertes Vokabular https://wissen.kulturpool.at/books/kontrollierte-vokabulare/page/einstieg-kontrollierte-vokabulare)
        #xml.tag!("dcterms:spatial", "...")         # (0..n) Räumliches Thema des Objekts
        # (0..n) Zeitliches Thema des Objekts
        datingStr = dating_phase ? dating_phase : "antik"
        if dating_from || dating_to
            datingStr = dating_years 
            datingStr += " (" + dating_phase + ")" if dating_phase
        end
        xml.tag!("dcterms:temporal", datingStr)   
      #--- RECOMMENDED fields
        # (0..1) Standort (Institution, Lagerort) des Kulturguts
        if conservation_place && conservation_place.full_name 
            currentlocStr = conservation_place.full_name 
            currentlocStr += ", " + conservation_comment if conservation_comment
            xml.tag!("edm:currentLocation", currentlocStr)
        elsif museum && museum.name
            currentlocStr = museum.name
            currentlocStr += ", Inv. No. " + museum_inventory_number if museum_inventory_number
            xml.tag!("edm:currentLocation", currentlocStr)
        end
        # (0..1) Herkunft des Objekts, Eigentümerwechsel
        if finding_place && finding_place.full_name
            provenanceStr = finding_place.full_name
            provenanceStr += " (" + ancient_finding_place.full_name + ")" if ancient_finding_place && ancient_finding_place.full_name
            provenanceStr += ", " + finding_comment if finding_comment
            xml.tag!("edm:provenance", provenanceStr)    
        end
        xml.tag!("dcterms:medium", material + (material_comment ? ", " + material_comment : "")) if material
        xml.tag!("dcterms:extent", width.sub(/^0+/, "") + " x " + height.sub(/^0+/, "") + " x " + depth.sub(/^0+/, "") + " (B x H x T cm)") if width && height && depth
        xml.tag!("dcterms:isReferencedBy", literature) if literature
        xml.tag!("dcterms:isReferencedBy", literature_online) if literature_online
      end
      #----------------------------------------------------------------------
      # export photo resources
      exportable_photos.each do |photo|
        xml.tag!("edm:WebResource", "rdf:about" => lupa_root_url + "/img/" + photo.filename) do
            # recommended fields
            xml.tag!("dc:type", "Image")           # (0..n) Medientyp des digitalen Objekts (z. B. Video)
            if photo.author && photo.author && photo.author.first_name && photo.author.last_name
                authorStr = photo.author.first_name + " " + photo.author.last_name
                authorStr += ", " + photo.author.institution if photo.author.institution
                xml.tag!("dc:creator", authorStr)         # (0..n) Zur Erschaffung des digitalen Objekts beitragende Person (z. B. Fotograf:in)
            end
            xml.tag!("dc:rights", photo.copyright.copyright)  # (0..n) Name der Person oder Organisation, welche über die Rechte verfügt
            xml.tag!("edm:rights", photo.copyright.copyright) # (0..1) Informationen zu Copyright und Nutzungsrechten (nur falls abweichend zum Nutzungsrecht im Aggregationsobjekt)
            # (0..n) Größe oder Dauer der Ressource (z. B. 4000 × 3000 px)
            xml.tag!("dcterms:extent", photo.width.to_s + " x " + photo.height.to_s + " px") if photo.width && photo.height
        end
      end
      # export 3d models
      if has_3d_model
        xml.tag!("edm:WebResource", "rdf:about" => model3d_url) do
            # recommended fields
            xml.tag!("dc:type", "3D")           # (0..n) Medientyp des digitalen Objekts (z. B. Video)
            xml.tag!("dc:creator", "Paul Victor Bayer")     # (0..n) Zur Erschaffung des digitalen Objekts beitragende Person (z. B. Fotograf:in)
            xml.tag!("dc:rights", "Ubi Erat Lupa")          # (0..n) Name der Person oder Organisation, welche über die Rechte verfügt
            #xml.tag!("edm:rights", "rdf:resource" => "http://creativecommons.org/licenses/by-nc/4.0/")          # (0..1) Informationen zu Copyright und Nutzungsrechten (nur falls abweichend zum Nutzungsrecht im Aggregationsobjekt)
        end
      end
      #----------------------------------------------------------------------
      xml.tag!("ore:Aggreation", "rdf:about" => aggregation) do
      # REQUIRED fields for EDM
        xml.tag!("edm:aggregatedCHO", "rdf:resource" => providedCHO)  # (1..1) Verbindung zur Kulturgut-Klasse über eine URI oder einen lokalen Identifikator, siehe https://europeana.atlassian.net/wiki/spaces/EF/pages/2106294284/edm+ProvidedCHO
        xml.tag!("edm:dataProvider", "Ubi Erat Lupa")   # (1..1) Name der Institution, die die Daten für den Kulturpool zur Verfügung stellt
        xml.tag!("edm:isShownAt", "rdf:resource" => monument_url)      # (0..1) Webadresse zum digitalen Objekt in vollem Kontext (Angabe als URL zur Seite mit Metadaten und Medienansicht)
        # (0..1) Webadresse zum digitalen Objekt, Link zur Mediendatei (z. B. URL zur Bilddatei). Nur ein Wert möglich, weitere Werte in Ansichten («edm:hasView») eintragen.
        if exportable_photos.exists?
            xml.tag!("edm:isShownBy", "rdf:resource" => lupa_root_url + "/img/" + exportable_photos.first.filename) 
        elsif has_3d_model
            xml.tag!("edm:isShownBy", "rdf:resource" => model3d_url) 
        #else
            # This should not happen since we only export if there are photos or a 3d model!
        end        
        xml.tag!("edm:rights", "rdf:resource" => "http://creativecommons.org/licenses/by-nc/4.0/")         # (1..1) (Copyright und Nutzungsrechte) des digitalen Objekts, Angabe als URI
      # recommended fields
        #xml.tag!("edm:hasView", "...")        # (0..n) Weitere Ressourcenadressen zum digitalen Objekt, etwa weitere Ansichten (z. B. Seitenansicht, Detailansicht)
      end
    end

    # Return the generated XML as a string
    xml.target!
  end
end
