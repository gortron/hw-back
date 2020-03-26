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
    # apply whatever sorts user has requested

    # tags ("science", "technology")
    # sortBy ("popularity")
    # order ("asc", "desc") 
    url = request.original_url
    uri = URI.parse(url)
    queries = CGI.parse(uri.query)
    tags = queries["tags"].first.split(",")
    sortBy = queries["sortBy"].first || "id"
    direction = queries["direction"].first || "asc"

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    response = [];
    uniquePosts = {};
    tags.each do |tag|
      target = endpoint + "tag=" + tag
      data = JSON.parse(RestClient.get(target))
      # look through posts that come back from API call
      # check if that posts id we've seen before
      # if it's new, let's note it in uniquePosts & push to response
      # if it's not, look to the next post (ignore it)

      data["posts"].each do |post|
        if !uniquePosts.key?(:post["id"]) 
          uniquePosts[post["id"]] = post
          # uniquePosts[post["id"]] = true
        end
      end
    end

    # build response array from uniqePosts
    uniquePosts.map { |k,v| response.push(v) }

    response = response.sort_by { |post| post["#{sortBy}"]}
    if (direction === "desc") 
      response = response.reverse
    end

    json_response(response)
  end
end
