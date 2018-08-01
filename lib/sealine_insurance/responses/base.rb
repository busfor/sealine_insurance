# frozen_string_literal: true

module SealineInsurance
  module Responses
    class Base
      attr_reader :body

      def initialize(http_response)
        @body = parse_response_body(http_response.body)
        if @body.nil?
          # ошибка парсинга JSON
          @success = false
          @error_code = 'invalid_response'
          @error_message = 'Invalid JSON'
          @body = {}
        elsif http_response.status == 401
          # ошибка авторизации
          @success = false
          @error_code = 'unauthorized'
          @error_message = body['detail']
        elsif http_response.status == 400
          # невалидные входные данные
          @success = false
          @error_code = 'invalid_params'
          @error_message = fetch_validation_error(body)
        elsif http_response.status == 409
          # еще один вариант ошибки - 409 Conflict
          @success = false
          @error_code = 'conflict'
          @error_message = body['error']
        else
          @success = true
        end
      end

      def success?
        @success
      end

      def error?
        !success?
      end

      def error_code
        @error_code ||= body['error_code']
      end

      def error_message
        @error_message ||= body['error_message']
      end

      private

      def parse_response_body(body)
        JSON.parse(body)
      rescue JSON::ParserError
        nil
      end

      # Ошибки валидации возвращаются в виде хэша различной вложенности.
      # Ключи хеша - поля, которые не прошли валидацию. Значение - текст ошибки.
      # Метод рекурсивный, он находит первую ошибку и возвращает ее в виде строки.
      # Пример возвращаемого значения:
      #   "data.arrival: Не может быть меньше даты trip.departure.date"
      def fetch_validation_error(data, key_path = [])
        if data.is_a?(Hash) && !data.empty?
          key = data.keys.first
          fetch_validation_error(data[key], key_path + [key])
        elsif data.is_a?(Array) && !data.empty? && data.all? { |item| item.is_a?(String) }
          fetch_validation_error(data.join(', '), key_path)
        elsif data.is_a?(String)
          "#{key_path.join('.')}: #{data}"
        end
      end
    end
  end
end
