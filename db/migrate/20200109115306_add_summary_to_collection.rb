class AddSummaryToCollection < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :summary, :string
  end
end
