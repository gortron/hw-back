class CreateCachedSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :cached_searches do |t|
      t.text :searchString
      t.timestamps
    end
  end
end
