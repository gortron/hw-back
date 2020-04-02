class CachedSearch < ActiveRecord::Base
  has_many :cached_results
  has_many :posts, through: :cached_results

  validates_presence_of :search_string, :created_at, :updated_at
end