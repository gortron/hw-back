class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :author
      t.integer :authorId
      t.integer :originId
      t.integer :likes
      t.decimal :popularity
      t.integer :reads
      t.text :tags, array: true
      t.timestamps
    end
  end
end
