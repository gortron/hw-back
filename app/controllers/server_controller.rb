
class ServerController < ApplicationController
  def ping
    message ={
      "success": true
     }
    json_response(message)
  end
end