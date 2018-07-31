# frozen_string_literal: true

module SealineInsurance
  class PaymentResponse < BaseResponse
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

    private

    def error_status?
      status == 'ERROR'
    end
  end
end
