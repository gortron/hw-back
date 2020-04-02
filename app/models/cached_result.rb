class CachedResult < ApplicationRecord
  belongs_to :post
  belongs_to :cached_search

  validates_presence_of :post_id, :cached_search_id
end