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
      raw_body['id']
    end

    def status
      raw_body['status']
    end

    def calculated?
      status == 'DONE'
    end

    def price
      result = raw_body['results']&.detect { |item| item['status'] == 'DONE' }
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
