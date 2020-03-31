class Post < ActiveRecord::Base
  has_many :cached_results
  has_many :cached_searches, through: :cached_results
end