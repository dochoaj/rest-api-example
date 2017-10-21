module V1
  module Middleware
    class TokenAuthenticable < Grape::Middleware::Base
      def initialize(_, _options = {})
        super
        define_current_entity_getter entity_class, getter_name
      end

      def before
        authenticate

        context.send(:instance_variable_set, var_name, send(getter_name))
        context.class.send(:define_method, getter_name) { instance_variable_get var_name }
      end

      def context
        env['api.endpoint']
      end

      def define_current_entity_getter(entity_class, getter_name)
        return if respond_to?(getter_name)

        self.class.send(:define_method, getter_name) do
          unless instance_variable_defined?(var_name)
            current =
              begin
                decoded_token = JsonWebToken.decode(token)
                raise ::JWT::DecodeError unless decoded_token
                entity_class.send(:find_by_id, decoded_token[identity.to_sym])
              rescue ::JWT::DecodeError
                nil
              end

            instance_variable_set(var_name, current)
          end

          instance_variable_get(var_name)
        end
      end

      def authenticate
        raise V1::Exceptions::Unauthorized unless token
        raise V1::Exceptions::Unauthorized unless send(getter_name)
      end

      def var_name
        "@_#{getter_name}"
      end

      def entity_class
        Object.const_get('User')
      end

      def identity
        'user_id'.freeze
      end

      def header_name
        'HTTP_AUTHORIZATION'.freeze
      end

      def getter_name
        'current_user'.freeze
      end

      def token
        env[header_name].to_s.split(' ').last
      end
    end
  end
end