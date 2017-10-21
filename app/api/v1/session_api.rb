module V1
  class SessionAPI < Grape::API
    resource :session do
      post :login do
        user = User.find_for_authentication(email: params[:email])
        raise V1::Exceptions::Unauthorized unless user.valid_password?(params[:password])
        { token: user.generate_token, user: user }
      end
    end
  end
end
