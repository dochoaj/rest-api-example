module V1
  # The root class for mouting the V1 API
  class Root < Grape::API
    version 'v1'
    format :json
    prefix :api

    rescue_from V1::Exceptions::Unauthorized do
      error!('403 Forbidden', 403)
    end

    get :status do
      { status: 'Ok' }
    end

    mount V1::ProtectedAPI
    mount V1::SessionAPI
  end
end