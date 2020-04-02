class Post < ActiveRecord::Base
  has_many :cached_results
  has_many :cached_searches, through: :cached_results

  validates_presence_of :author, :author_id, :origin_id, :likes, :popularity, :reads, :tags
end