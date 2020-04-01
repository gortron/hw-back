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
      return json_response({"error": "Queries must be provided. Try: /api/posts?tags=tech&sortBy=likes"}, 400)
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
        "error": "Direction parameter is invalid. Try: asc, desc"
        }, 400)
    end

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    response = [];
    unique_posts = {};

    sorted_tag_string = tags.sort.join(",")
    sanitized_search = "#{endpoint}tags=#{sorted_tag_string}"
    cached = CachedSearch.find_by(search_string: sanitized_search) || nil

    if (cached && (Time.now - cached[:created_at] < 72*60*60))
      posts = cached.posts
      posts.each do |post|
        structured_post = {author: post.author, author_id: post.author_id, id: post.origin_id, likes: post.likes, popularity: post.popularity, reads: post.reads, tags: JSON.parse(post.tags)}
        response.push(structured_post)
      end
      # when we read, response interprets post[:sort_by]
      response = response.sort_by { |post| post[:"#{sort_by}"]}
      if (direction === "desc") 
        response = response.reverse
      end
    else
      new_search = CachedSearch.create(search_string: sanitized_search)
      tags.each do |tag|
        target = endpoint + "tag=" + tag
        data = JSON.parse(RestClient.get(target))
  
        data["posts"].each do |post|
          if !unique_posts.key?(:post["id"]) 
            unique_posts[post["id"]] = post
          end
        end
      end
  
      if unique_posts.empty?
        return json_response({
          "message": "Couldn't find any posts for those parameters. Try: /api/posts?tags=tech&sortBy=likes"
          }, 404)
      end

      unique_posts.each do |k,v| 
        new_post = Post.create(author: v["author"], author_id: v["authorId"], origin_id: v["id"], likes: v["likes"], popularity: v["popularity"], reads: v["reads"], tags: v["tags"])
        CachedResult.create(cached_search_id: new_search.id, post_id: new_post.id)
        response.push(v) 
      end

      # when we write, response interprets post["sort_by"]
      response = response.sort_by { |post| post["#{sort_by}"]}
      if (direction === "desc") 
        response = response.reverse
      end
    end   

    return json_response(response)
  end
end
