require 'rails_helper'

RSpec.describe "Posts", type: :request do
  # initialize test data 
  let(:user) { create(:user) }
  let(:url) { '/authenticate' }
  let(:params) do
    {
      email: user.email,
      password: user.password
    }
  end
  before do
    post url, params: params
  end

  let(:token) { response.body }
 

  let!(:posts) { create_list(:post, 10) }
  let(:post_id) { posts.first.id }

  describe "GET /posts" do

    # make HTTP get request before each example
    before { get '/posts', params: {}, headers: { 'Authorization': JSON.parse(token)['auth_token'] } }

    it 'returns posts' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

   # Test suite for GET /posts/:id
   describe 'GET /posts/:id' do
    before { get "/posts/#{post_id}", params: {}, headers: { 'Authorization': JSON.parse(token)['auth_token'] } }

    context 'when the record exists' do
      it 'returns the post' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(post_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:post_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for POST /posts
  describe 'POST /posts' do
    # valid payload
    let(:valid_attributes) { create(:post) }

    context 'when the request is valid' do
      before { post '/posts', params: create(:post).to_json, headers: { 'Authorization': JSON.parse(token)['auth_token'] } }
      
      it 'creates a post' do
        puts valid_attributes
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/posts', params: { post: { title: 'Foobar'} }, headers: { 'Authorization': JSON.parse(token)['auth_token'] } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for PUT /posts/:id
  describe 'PUT /posts/:id' do
    let(:valid_attributes) { { post: { title: 'Shopping' } }   }

    context 'when the record exists' do
      before { put "/posts/#{post_id}", params: valid_attributes, headers: { 'Authorization': JSON.parse(token)['auth_token'] } }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for DELETE /posts/:id
  describe 'DELETE /posts/:id' do
    before { delete "/posts/#{post_id}", headers: { 'Authorization': JSON.parse(token)['auth_token'] } }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
