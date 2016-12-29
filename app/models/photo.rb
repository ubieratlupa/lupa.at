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

    lines = []
    if copyrights
      lines.append copyrights.join(' ')
    end
    
    photography = []
    if self.author
      photography.append "#{self.author.first_name} #{self.author.last_name}"
    end
    if self.year
      photography.append self.year
    end
    
    if photography
      lines.append "Fotografie: " + photography.join(', ')
    end
      
    lines.join("\n")
  end
end
