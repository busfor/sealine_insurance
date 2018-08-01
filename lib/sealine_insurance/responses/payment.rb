# frozen_string_literal: true

module SealineInsurance
  module Responses
    class Payment < Base
      STATUSES = [
        'IN_PROGRESS',  # Обрабатывается
        'DONE',         # Выполнено
        'ERROR',        # Ошибка
      ].freeze

      def payment_id
        body['id']
      end

      def order_id
        body['order']
      end

      def status
        body['status']
      end
    end
  end
end
