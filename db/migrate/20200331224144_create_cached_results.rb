class CreateCachedResults < ActiveRecord::Migration[6.0]
  def change
    create_table :cached_results do |t|
      t.integer :post_id
      t.integer :cached_search_id

      t.timestamps
    end
  end
end
