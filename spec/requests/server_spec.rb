require 'rails_helper'

RSpec.describe 'API', type: :request do

  describe 'GET /api/ping' do
    before { get '/api/ping' }

    it 'returns success message' do
      json = JSON.parse(response.body)
      expect(json).not_to be_empty
      expect(json.size).to eq(1)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /api/posts' do

    context 'when request is valid' do
      before { get '/api/posts?tags=science,tech,history&sortBy=reads&direction=desc' }
  
      it 'returns posts' do
        json = JSON.parse(response.body)
        expect(json).not_to be_empty
        expect(json.size).to be > 1
      end
  
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when request is invalid: no query' do
      before { get '/api/posts' }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when request is invalid: empty queries' do
      before { get '/api/posts?' }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    # context 'when request is valid but tags are invalid' do
    #   before { get '/api/posts?tags=' }

    #   it 'returns status code 400' do
    #     expect(response).to have_http_status(400)
    #   end
    # end

    context 'when request is valid but tags have no results' do
      before { get '/api/posts?tags=test_tag1,test_tag2' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

  end
end