class AuthorsController < ApplicationController

  def show
    @author = Author.find(params[:id])
    @photos = 
      Photo.where('id in (select min(id) as id from photos where visible and author_id = ? group by monument_id)', params[:id])
        .order(:monument_id => :desc)
        .page(params[:page]).per(48)
  end
  
  def photo
    @authors = Author.find_by_sql("
      select authors.*, count(distinct monument_id) as monument_count
      from vocabulary.authors 
      join photos on authors.id = photos.author_id
      where authors.visible and photos.visible
      group by authors.id
      order by authors.last_name, authors.first_name
    ")
    @page = Page.find('photo-authors-index')
  end

end
