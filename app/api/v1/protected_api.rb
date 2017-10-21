module V1
  class ProtectedAPI < Grape::API
    use V1::Middleware::TokenAuthenticable

    get :protected do
      { status: 'Ok protected' }
    end
  end
end