# frozen_string_literal: true

module SealineInsurance
  module Responses
    class Calculate < Base
      STATUSES = [
        'IN_PROGRESS',      # Обрабатывается
        'DONE',             # Выполнено
        'DONE_WITH_ERRORS', # Выполнено с ошибками
        'ERROR',            # Ошибка
      ].freeze

      def request_id
        body['id']
      end

      def status
        body['status']
      end

      def price
        to_money(result['price'])
      end

      def coverage
        to_money(result.dig('result_data', 'coverage'))
      end

      private

      def result
        @result ||= body['results']&.detect { |item| item['status'] == 'DONE' } || {}
      end
    end
  end
end
