class AddCollectionsIndexView < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE VIEW web_queries.collections_index AS  WITH monument_counts AS (
               SELECT monuments.collection_id,
                  count(*) AS monument_count
                 FROM monuments
                WHERE monuments.visible and monuments.collection_id is not null
                GROUP BY monuments.collection_id
              )
       SELECT collections.*,
          monument_counts.monument_count,
          places.name AS place_name,
          "substring"(places.full_name, ' ?([^,]+)$'::text) AS country_name
         FROM collections
           LEFT JOIN monument_counts ON monument_counts.collection_id = collections.id
           JOIN vocabulary.places ON places.id = collections.place_id
        ORDER BY places.name;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW web_queries.collections_index;
      SQL
  end
end
