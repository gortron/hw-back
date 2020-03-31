class CachedResult < ApplicationRecord
  belongs_to :post
  belongs_to :cached_search
end