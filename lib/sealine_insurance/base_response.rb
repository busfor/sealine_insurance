# frozen_string_literal: true

module SealineInsurance
  class BaseResponse
    attr_reader :raw_body
    attr_reader :error_code
    attr_reader :error_message

    def initialize(http_response)
      @raw_body = parse_response_body(http_response.body)
      if @error_code
        # ошибка парсинга JSON
        @success = false
      elsif http_response.status == 401
        # ошибка авторизации
        @success = false
        @error_code = 'unauthorized'
        @error_message = raw_body['detail']
      elsif http_response.status == 400
        # невалидные входные данные
        @success = false
        @error_code = 'invalid_params'
        @error_message = fetch_validation_error(raw_body)
      else
        # определение ошибки по статусу в JSON
        # если !error_status? - считаем ответ успешным
        @success = !error_status?
        @error_code = raw_body['error_code']
        @error_message = raw_body['error_message']
      end
    end

    def success?
      @success
    end

    def error?
      !success?
    end

    private

    # Дочерние классы переопределяют этот метод.
    # В общем случае статуса в raw_body может не быть, поэтому по дефолту false.
    def error_status?
      false
    end

    def parse_response_body(body)
      JSON.parse(body)
    rescue JSON::ParserError
      @error_code = 'invalid_response'
      @error_message = 'Invalid JSON'
      {}
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
