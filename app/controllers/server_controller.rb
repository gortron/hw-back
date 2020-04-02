require 'rest-client'

class ServerController < ApplicationController
  before_action :post_params, only: [:posts]

  def ping
    message = { "success": true }
    json_response(message)
  end


  # <ActionController::Parameters {"tags"=>"science,culture", "sortBy"=>"popularity", "direction"=>"desc", "controller"=>"server", "action"=>"posts"} permitted: false>
  def posts
    begin
      tags = params[:tags].split(",") || []
      sort_by = params[:sortBy] || "id"
      direction = params[:direction] || "asc"
    rescue
      return json_response({"error": "Queries must be provided. Try: /api/posts?tags=tech&sortBy=likes"}, 400)
    end

    validate_post_params(tags, sort_by, direction)    

    endpoint = 'http://hatchways.io/api/assessment/blog/posts?'
    sorted_tag_string = tags.sort.join(",")
    sanitized_search = "#{endpoint}tags=#{sorted_tag_string}"
    cached = CachedSearch.find_by(search_string: sanitized_search) || nil

    # If we found a recent cached search, pull the corresponding posts from db
    if (cached && (Time.now - cached[:created_at] < 72*60*60))
      response = get_cached_results(cached)
      # Order our response based on query params

    # If there's no cached search, then cache current search & make external calls
    else
      response = create_results(tags, endpoint, sanitized_search)
      # Check if create_results returns a no results message
      if (response.size == 1 && response.first.first == :message) 
        return json_response(response, 404)
      end
    end   

    response = response.sort_by { |post| post[:"#{sort_by}"]}
    if (direction === "desc") 
      response = response.reverse
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

  def get_cached_results(cached)
    response = []
    posts = cached.posts

    # Structure data for response to look like external API
    posts.each do |post|
      structured_post = {author: post.author, author_id: post.author_id, id: post.origin_id, likes: post.likes, popularity: post.popularity, reads: post.reads, tags: JSON.parse(post.tags)}
      response.push(structured_post)
    end

    return response
  end

  def create_results(tags, endpoint, sanitized_search)
    response = []
    unique_posts = {}
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
      return {"message": "Couldn't find any posts for those parameters. Try: /api/posts?tags=tech&sortBy=likes"}
    end

    # Restructure data from external APi to fit app db
    unique_posts.each do |origin_id, post_data| 
      post = Post.create_with(author: post_data["author"], author_id: post_data["authorId"], likes: post_data["likes"], popularity: post_data["popularity"].to_f, reads: post_data["reads"], tags: post_data["tags"]).find_or_create_by(origin_id: origin_id)
      CachedResult.create(cached_search_id: new_search.id, post_id: post.id)

      structured_post = {author: post.author, author_id: post.author_id, id: post.origin_id, likes: post.likes, popularity: post.popularity, reads: post.reads, tags: JSON.parse(post.tags)}

      response.push(structured_post) 
    end

    return response
  end
end
