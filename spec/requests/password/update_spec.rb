describe 'API Password' do
  describe 'PUT /users/password' do
    context 'when User exists' do
      let(:user) { create(:user, password: '12345678') }
      let!(:reset_pw_token) { user.send_reset_password_instructions }

      context 'with valid params' do
        context 'when passing valid token' do
          it 'updates password' do
            put '/users/password',
              format: :json,
              user: {
                reset_password_token: reset_pw_token,
                password: 'new_12345678',
                password_confirmation: 'new_12345678'
              }

            user.reload
            expect(user.reset_password_token).to eq nil
            expect(user.valid_password?('new_12345678')).to eq true

            expect(response.body.blank?).to eq true
            expect(response.status).to eq 204
          end
        end
      end

      context 'with invalid params' do
        context 'when passing invalid token' do
          it 'does not update password' do
            put '/users/password',
              format: :json,
              user: {
                reset_password_token: 'invalid-token',
                password: 'new_12345678',
                password_confirmation: 'new_12345678'
              }

            user.reload
            expect(user.reset_password_token.present?).to eq true
            expect(user.valid_password?('new_12345678')).to eq false

            expect(json).to eq('errors' => { 'reset_password_token' => ['is invalid'] })
            expect(response.status).to eq 422
          end
        end

        context 'when passing invalid password' do
          it 'does not update password' do
            put '/users/password',
              format: :json,
              user: {
                reset_password_token: reset_pw_token,
                password: '1',
                password_confirmation: '2'
              }

            user.reload
            expect(user.reset_password_token.present?).to eq true
            expect(user.valid_password?('1')).to eq false
            expect(user.valid_password?('2')).to eq false

            expect(json).to eq(
              'errors' => {
                'password_confirmation' => ["doesn't match Password"],
                'password' => ['is too short (minimum is 8 characters)']
              })
            expect(response.status).to eq 422
          end
        end
      end
    end
  end
end
