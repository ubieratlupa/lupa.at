class Page < ActiveRecord::Base
  belongs_to :photo, optional: true
  
  def display_text
    display_text = text || ''
    display_text.gsub! "NUMBER_OF_PHOTOS", Photo.all.size.to_s if display_text.match("NUMBER_OF_PHOTOS")
    display_text.gsub! "NUMBER_OF_MONUMENTS", Monument.all.size.to_s if display_text.match("NUMBER_OF_MONUMENTS")
    display_text
  end
  
  def display_title
    display_title = title || ''
    display_title.gsub! "NUMBER_OF_PHOTOS", Photo.all.size.to_s if display_title.match("NUMBER_OF_PHOTOS")
    display_title.gsub! "NUMBER_OF_MONUMENTS", Monument.all.size.to_s if display_title.match("NUMBER_OF_MONUMENTS")
    display_title
  end
  
end