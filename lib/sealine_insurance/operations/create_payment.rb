# frozen_string_literal: true

module SealineInsurance
  module Operations
    class CreatePayment < Base
      def initialize(config:, order_id:)
        super(config: config)
        @order_id = order_id
      end

      def call
        raw_response = request.post('/payment', order: @order_id)
        @response = Responses::Payment.new(raw_response)
      end

      def fetch_status!
        raw_response = request.get("/order/#{@order_id}")
        @response = Responses::Order.new(raw_response)
      end

      private

      def finished_status_list
        @finished_status_list ||= [
          'DONE',   # Выполнено
          'ERROR',  # Ошибка
        ]
      end

      def success_status_list
        @success_status_list ||= ['DONE']
      end
    end
  end
end
