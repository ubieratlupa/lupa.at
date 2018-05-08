class AuthorsController < ApplicationController

  def show
    @author = Author.find(params[:id])
    @photos = Photo.where(author_id: params[:id]).where('monument_id is not null').order(:monument_id => :desc).page(params[:page]).per(48)
  end
  
  def photo
    @authors = Author.find_by_sql("
      select authors.*, count(1) as photo_count
      from vocabulary.authors 
      join photos on authors.id = photos.author_id
      where authors.visible
      group by authors.id
      order by authors.last_name, authors.first_name
    ")
    @page = Page.find('photo-authors-index')
  end

end
