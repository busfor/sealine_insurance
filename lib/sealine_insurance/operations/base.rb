# frozen_string_literal: true

# Часть методов в API асинхронные. Класс предоставляет абстракцию для них.
# Работа с API выглядит примерно так:
# 1. Запрос на выполнение действия.
# 2. Запрос актуального статуса до тех пор, пока операция не будет завершена.
module SealineInsurance
  module Operations
    class Base
      # Промежуточный ответ сервера
      attr_reader :response

      def initialize(config:)
        @config = config
      end

      # Запуск операции
      def call
        raise NotImplementedError
      end

      # Получение актуального статуса выполнения и результата
      def fetch_result!
        raise NotImplementedError
      end

      # Завершена ли операция (с успехом или ошибкой)
      def finished?
        raise NotImplementedError
      end

      # Завершена ли операция с успехом
      def success?
        raise NotImplementedError
      end

      # Окончательный результат операции (успешный или нет)
      def result
        response if finished?
      end

      private

      def request
        @request ||= Request.new(config: @config)
      end
    end
  end
end
