require 'rest-client'

class ServerController < ApplicationController
  def ping
    message = { "success": true }
    json_response(message)
  end

  # if we wanted to cache our results, we would need to save the final result for any given uri... add a new model, CachedSearches
  # CachedSearches have-many posts. Before external query, we check CachedSearches
  def posts
    # figure out terms for our fetch
    # test if terms are valid
    # fetch all posts for each tag in URL query
    # combine all posts from the fetch, remove duplicates
    url = request.original_url
    uri = URI.parse(url)
    queries = CGI.parse(uri.query)
    tags = queries["tags"].first.split(",")
    sortBy = queries["sortBy"].first
    direction = queries["direction"].first

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    posts = [];
    tags.each do |tag|
      target = endpoint + "tag=" + tag
      data = JSON.parse(RestClient.get(target))
      posts.push(data["posts"])
    end
    # target = endpoint + "tag=" + tags.first


    message = { "hello": 'posts' }
    json_response(message)
  end
end
