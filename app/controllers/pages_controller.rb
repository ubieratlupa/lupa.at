class PagesController < ApplicationController

  def about
    website_text = WebsiteText.find("about-de")
    @title = website_text.title
    @text = website_text.text
    @text.gsub! "NUMBER_OF_PHOTOS", Photo.all.size.to_s
    @text.gsub! "NUMBER_OF_MONUMENTS", Monument.all.size.to_s
  end

end
