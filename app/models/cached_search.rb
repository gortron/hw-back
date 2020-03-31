class CachedSearch < ActiveRecord::Base
  has_many :cached_results
  has_many :posts, through: :cached_results
end