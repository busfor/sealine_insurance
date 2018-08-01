# frozen_string_literal: true

module SealineInsurance
  module Operations
    class CreatePayment < Base
      FINISHED_STATES = [
        'DONE',   # Выполнено
        'ERROR',  # Ошибка
      ].freeze

      SUCCESS_STATES = [
        'DONE',   # Выполнено
      ].freeze

      def initialize(config:, order_id:)
        super(config: config)
        @order_id = order_id
      end

      def call
        raw_response = request.post('/payment', order: @order_id)
        @response = Responses::Payment.new(raw_response)
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
