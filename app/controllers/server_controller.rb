require 'rest-client'

class ServerController < ApplicationController
  before_action :post_params, only: [:posts]

  def ping
    message = { "success": true }
    json_response(message)
  end


  # <ActionController::Parameters {"tags"=>"science,culture", "sortBy"=>"popularity", "direction"=>"desc", "controller"=>"server", "action"=>"posts"} permitted: false>
  def posts
    # Parse query params out of request
    # begin
    #   url = request.original_url
    #   uri = URI.parse(url)
    #   raise NoMethodError unless queries = CGI.parse(uri.query)
    # rescue
    #   return json_response({"error": "Queries must be provided. Try: /api/posts?tags=tech&sortBy=likes"}, 400)
    # end
    # byebug
    # tags = queries["tags"] || []
    # sort_by = queries["sortBy"].first || "id"
    # direction = queries["direction"].first || "asc"
    tags = params[:tags].split(",") || []
    sort_by = params[:sortBy] || "id"
    direction = params[:direction] || "asc"

    validate_post_params(tags, sort_by, direction)    

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    response = [];
    unique_posts = {};

    sorted_tag_string = tags.sort.join(",")
    sanitized_search = "#{endpoint}tags=#{sorted_tag_string}"
    cached = CachedSearch.find_by(search_string: sanitized_search) || nil

    # If we found a recent cached search, pull the corresponding posts from db
    if (cached && (Time.now - cached[:created_at] < 72*60*60))
      posts = cached.posts

      # Structure data for response to look like external API
      posts.each do |post|
        structured_post = {author: post.author, author_id: post.author_id, id: post.origin_id, likes: post.likes, popularity: post.popularity, reads: post.reads, tags: JSON.parse(post.tags)}
        response.push(structured_post)
      end

      # Order our response based on query params
      response = response.sort_by { |post| post[:"#{sort_by}"]}
      if (direction === "desc") 
        response = response.reverse
      end

    # If there's no cached search, then cache current search & make external calls
    else
      new_search = CachedSearch.create(search_string: sanitized_search)

      # Each tag represents a call to make to the external API, only keep unique posts
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
        CachedSearch.last.destroy
        return json_response({
          "message": "Couldn't find any posts for those parameters. Try: /api/posts?tags=tech&sortBy=likes"
          }, 404)
          
      end

      # Restructure data from external APi to fit app db
      unique_posts.each do |k,v| 
        new_post = Post.create(author: v["author"], author_id: v["authorId"], origin_id: v["id"], likes: v["likes"], popularity: v["popularity"], reads: v["reads"], tags: v["tags"])
        CachedResult.create(cached_search_id: new_search.id, post_id: new_post.id)
        response.push(v) 
      end

      response = response.sort_by { |post| post["#{sort_by}"]}
      if (direction === "desc") 
        response = response.reverse
      end
    end   

    return json_response(response)
  end

  private

  def post_params
    params.permit(:tags, :sortBy, :direction)
  end

  def validate_post_params(tags, sort_by, direction)
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
  end
end
