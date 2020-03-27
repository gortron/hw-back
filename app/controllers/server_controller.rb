require 'rest-client'

class ServerController < ApplicationController
  def ping
    message = { "success": true }
    json_response(message)
  end

  # if we wanted to cache our results, we would need to save the final result for any given uri... add a new model, CachedSearches
  # CachedSearches have-many posts. Before external query, we check CachedSearches
  def posts
    begin
      url = request.original_url
      uri = URI.parse(url)
      raise NoMethodError unless queries = CGI.parse(uri.query)
    rescue
      return json_response({"error": "queries must be provided. Try: /api/posts?tags=tech&sortBy=likes"}, 400)
    end
    
    tags = queries["tags"] || []
    sort_by = queries["sortBy"].first || "id"
    direction = queries["direction"].first || "asc"


    if (tags.empty?)
      return json_response({"error": "Tags parameter is required"}, 400)
    else
      tags = tags.first.split(",")
    end

    valid_sorts = ["author", "authorId", "id","likes", "popularity", "reads"]
    if (!valid_sorts.include?(sort_by))
      return json_response({
        "error": "sortBy parameter is invalid. Try: id, author, authorId, likes, popularity, reads"
        }, 400)
    end
    
    valid_directions = ["asc", "desc"]
    if (!valid_directions.include?(direction))
      return json_response({
        "error": "direction parameter is invalid. Try: asc, desc"
        }, 400)
    end

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    response = [];
    unique_posts = {};
    tags.each do |tag|
      target = endpoint + "tag=" + tag
      data = JSON.parse(RestClient.get(target))

      data["posts"].each do |post|
        if !unique_posts.key?(:post["id"]) 
          unique_posts[post["id"]] = post
        end
      end
    end


    unique_posts.map { |k,v| response.push(v) }
    response = response.sort_by { |post| post["#{sort_by}"]}
    if (direction === "desc") 
      response = response.reverse
    end

    return json_response(response)
  end
end
