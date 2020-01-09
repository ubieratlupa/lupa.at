class AddCollectionRefToMonuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :monuments, :collection, foreign_key: true
  end
end
