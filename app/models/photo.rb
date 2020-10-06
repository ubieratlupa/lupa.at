class Photo < ActiveRecord::Base
  belongs_to :copyright, optional: true
  belongs_to :author, optional: true
  belongs_to :monument, optional: true
  
  def caption
    copyrights = []
    if self.copyright
      copyrights.append self.copyright.copyright
    end
    if self.copyright_detail
      copyrights.append self.copyright_detail
    end

    lines = []
    if copyrights.count > 0
      lines.append copyrights.join(' ')
    end
    
    photography = []
    if self.author
      if self.author.credit_name
        photography.append self.author.credit_name
      else
        photography.append "#{self.author.first_name} #{self.author.last_name}"
      end
    end
    if self.year
      photography.append self.year
    end
    
    if photography.count > 0
      lines.append "Foto: " + photography.join(' ')
    end
      
    lines.join(", ")
  end
end
