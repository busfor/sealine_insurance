# frozen_string_literal: true

module SealineInsurance
  class CalculateResponse < BaseResponse
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

    def calculated?
      status == 'DONE'
    end

    def price
      result = body['results']&.detect { |item| item['status'] == 'DONE' }
      if result && result['price']
        Money.new(result['price'], DEFAULT_CURRENCY)
      end
    end

    private

    def error_status?
      %w[DONE_WITH_ERRORS ERROR].include?(status)
    end
  end
end
