# frozen_string_literal: true

module SealineInsurance
  class CancelOrder < AsyncOperation
    FINISHED_STATES = [
      'REPEAT_CANCELLATION', # Требуется повтор отмены
      'NOT_CANCELLED',       # Не отменен
      'CANCELLED',           # Отменен
    ].freeze

    SUCCESS_STATES = [
      'CANCELLED',           # Отменен
    ].freeze

    def call
      raw_response = request.delete("/order/#{order_id}")
      @response = OrderResponse.new(raw_response)
    end

    def fetch_result!
      raw_response = request.get("/order/#{order_id}")
      @response = OrderResponse.new(raw_response)
    end

    def finished?
      FINISHED_STATES.include?(response.status)
    end

    def success?
      SUCCESS_STATES.include?(response.status)
    end

    private

    def order_id
      arguments[:order_id]
    end
  end
end
