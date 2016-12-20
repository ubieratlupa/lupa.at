class Photo < ActiveRecord::Base
  belongs_to :copyright, optional: true
  belongs_to :author, optional: true
  
  def caption
    copyrights = []
    if self.copyright
      copyrights.append self.copyright.copyright
    end
    if self.copyright_detail
      copyrights.append self.copyright_detail
    end

    captions = []
    if copyrights
      captions.append copyrights.join(' ')
    end
    if self.author
      captions.append "Fotograf: #{self.author.first_name} #{self.author.last_name}"
    end
    if self.year
      captions.append self.year
    end
    captions.join(', ')
  end
end
