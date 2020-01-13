class AddLinksToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :link_1, :string
    add_column :collections, :link_2, :string
    add_column :collections, :link_3, :string
  end
end
