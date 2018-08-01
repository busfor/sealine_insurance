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
      def fetch_status!
        raise NotImplementedError
      end

      # Завершена ли операция (с успехом или ошибкой)
      def finished?
        response.error? || finished_status_list.include?(response.status)
      end

      # Завершена ли операция с успехом
      def success?
        response.success? && success_status_list.include?(response.status)
      end

      # Окончательный результат операции (успешный или нет)
      def result
        response if finished?
      end

      private

      # Массив статусов, соответствующий завершенной операции
      def finished_status_list
        raise NotImplementedError
      end

      # Массив статусов, соответствующий успешно завершенной операции
      def success_status_list
        raise NotImplementedError
      end

      def request
        @request ||= Request.new(config: @config)
      end
    end
  end
end
