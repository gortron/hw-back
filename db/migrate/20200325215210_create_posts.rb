class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :author
      t.integer :author_id
      t.integer :origin_id
      t.integer :likes
      t.float :popularity
      t.integer :reads
      t.text :tags, array: true
      t.timestamps
    end
  end
end
