# frozen_string_literal: true

# Часть методов в API асинхронные. Класс предоставляет абстракцию для них.
module SealineInsurance
  class AsyncOperation
    attr_reader :arguments
    attr_reader :response

    def initialize(config:, arguments: {})
      @config = config
      @arguments = arguments
    end

    # запус операции
    def call
      raise NotImplementedError
    end

    # получение актуального статуса выполнения и результата
    def fetch_result!
      raise NotImplementedError
    end

    # завершена ли операция (с успехом или ошибкой)
    def finished?
      raise NotImplementedError
    end

    # завершена ли операция с успехом
    def success?
      raise NotImplementedError
    end

    private

    def request
      @request ||= Request.new(config: @config)
    end
  end
end
