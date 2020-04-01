# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Post.destroy_all
CachedSearch.destroy_all
CachedResult.destroy_all

data = {
  author: "Elisha Friedman",
  author_id: 8,
  origin_id: 4,
  likes: 728,
  popularity: 0.88,
  reads: 19645,
  tags: [
    "science",
    "design",
    "tech"
  ]
}

post = Post.create(data)

# search = {
#   sort_by: "id",
#   direction: "asc",
#   tags: ["history", "science"],
#   post_origin_ids: [4]
# }

search = {search_string: "http://localhost:3000/api/posts?tags=history,tech&sortBy=popularity"}

cached_search = CachedSearch.create(search)

CachedResult.create(post_id: post.id, cached_search_id: cached_search.id)