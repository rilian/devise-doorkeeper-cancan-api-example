describe 'Authentication' do
  describe 'POST /oauth/token' do
    describe 'grant_type password' do
      context 'with valid params' do
        let(:user) { create :user, email: 'user@example.com', password: '12345678' }

        it 'returns token' do
          post '/oauth/token',
            'grant_type' => 'password',
            'username' => user.email,
            'password' => '12345678'

          expect(json['access_token'].size).to eq 64
          expect(json['refresh_token'].size).to eq 64
          expect(json['token_type']).to eq 'bearer'
          expect(json['expires_in']).to eq 7200
          expect(json['created_at'].present?).to eq true
          expect(response.status).to eq 200
        end
      end

      context 'when credentials are not valid' do
        it 'returns error' do
          post '/oauth/token',
            'grant_type' => 'password',
            'username' => 'invalid@example.com',
            'password' => 'invalid'

          expect(json).to eq(
            'error' => 'invalid_grant',
            'error_description' => 'The provided authorization grant is invalid, expired, revoked, does not match ' \
              'the redirection URI used in the authorization request, or was issued to another client.')
          expect(response.status).to eq 401
        end
      end
    end

    describe 'grant_type client_credentials' do
      context 'with valid params' do
        let(:client_application) { create :client_application }

        it 'returns token' do
          post '/oauth/token',
            'grant_type' => 'client_credentials',
            'client_id' => client_application.uid,
            'client_secret' => client_application.secret

          expect(json['access_token'].size).to eq 64
          expect(json['refresh_token']).to eq nil
          expect(json['token_type']).to eq 'bearer'
          expect(json['expires_in']).to eq 7200
          expect(json['created_at'].present?).to eq true
          expect(response.status).to eq 200
        end
      end
    end

    describe 'grant_type refresh_token' do
      let(:user) { create :user, email: 'user@example.com', password: '12345678' }
      let(:client_application) { create :client_application }
      let(:refresh_token) do
        client_application.access_tokens.create!(use_refresh_token: true, resource_owner_id: user.id).refresh_token
      end

      it 'returns new refresh_token' do
        post '/oauth/token',
          'grant_type' => 'refresh_token',
          'refresh_token' => refresh_token,
          'client_id' => client_application.uid,
          'client_secret' => client_application.secret

        expect(json['access_token'].size).to eq 64
        expect(json['refresh_token'].size).to eq 64
        expect(json['refresh_token'].size).to_not eq refresh_token
        expect(json['token_type']).to eq 'bearer'
        expect(json['expires_in']).to eq 7200
        expect(json['created_at'].present?).to eq true
        expect(response.status).to eq 200
      end
    end
  end
end
