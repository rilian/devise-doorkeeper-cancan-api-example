describe 'Root PATCH /api/users/:id' do
  describe 'GET /' do
    it 'returns message' do
      get '/'

      expect(json).to eq('errors' => ['Please check API documentation'])
      expect(response.status).to eq 200
    end
  end

  describe 'GET /robots.txt' do
    it 'returns message' do
      get '/robots.txt'

      expect(response.body).to eq("User-agent: *\nDisallow: /\n")
      expect(response.status).to eq 200
    end
  end
end
