# frozen_string_literal: true

module SealineInsurance
  module Operations
    class CancelOrder < Base
      FINISHED_STATES = [
        'REPEAT_CANCELLATION', # Требуется повтор отмены
        'NOT_CANCELLED',       # Не отменен
        'CANCELLED',           # Отменен
      ].freeze

      SUCCESS_STATES = [
        'CANCELLED',           # Отменен
      ].freeze

      def initialize(config:, order_id:)
        super(config: config)
        @order_id = order_id
      end

      def call
        raw_response = request.delete("/order/#{@order_id}")
        @response = Responses::Order.new(raw_response)
      end

      def fetch_result!
        raw_response = request.get("/order/#{@order_id}")
        @response = Responses::Order.new(raw_response)
      end

      def finished?
        FINISHED_STATES.include?(response.status) || response.error?
      end

      def success?
        SUCCESS_STATES.include?(response.status)
      end
    end
  end
end
