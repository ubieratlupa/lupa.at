class AddPubpermToCopyrights < ActiveRecord::Migration[5.2]
  def change
    add_column :copyrights, :publication_permission_required, :boolean, default: true, null: false
  end
end
