class Page < ActiveRecord::Base
  belongs_to :photo, optional: true
end