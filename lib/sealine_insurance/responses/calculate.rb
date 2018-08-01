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
        result = body['results']&.detect { |item| item['status'] == 'DONE' }
        if result && result['price']
          Money.from_amount(result['price'].to_f, DEFAULT_CURRENCY)
        end
      end
    end
  end
end
