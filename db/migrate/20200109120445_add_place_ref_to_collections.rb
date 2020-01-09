class AddPlaceRefToCollections < ActiveRecord::Migration[5.2]
  def change
    add_reference :collections, :place, foreign_key: true
  end
end
