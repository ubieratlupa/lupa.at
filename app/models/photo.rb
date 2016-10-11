class Photo < ActiveRecord::Base
  belongs_to :copyright, optional: true
  belongs_to :author, optional: true
  
  def caption
    caption = ''
    if self.author
      caption += self.author.first_name + ' ' + self.author.last_name + ' '
    end
    caption += self.copyright.try(:copyright) || ''
    caption += ' '
    caption += self.copyright_detail || ''
    caption
  end
end
