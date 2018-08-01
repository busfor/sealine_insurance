# frozen_string_literal: true

module SealineInsurance
  module Operations
    class Calculate < Base
      def initialize(config:, product_type:, products:, ticket_price:, options: [])
        super(config: config)
        @product_type = product_type
        @products = products
        @ticket_price = ticket_price
        @options = options
      end

      def call
        raw_response = request.post('/calculate-product',
          product_type: @product_type,
          products: @products,
          options: @options,
          data: {
            ticket_price: @ticket_price.to_i,
          },
        )
        @response = Responses::Calculate.new(raw_response)
        @request_id = @response.request_id
      end

      def fetch_result!
        return unless @request_id

        raw_response = request.get("/calculate-product/#{@request_id}")
        @response = Responses::Calculate.new(raw_response)
      end

      private

      def finished_status_list
        @finished_status_list ||= [
          'DONE',             # Выполнено
          'DONE_WITH_ERRORS', # Выполнено с ошибками
          'ERROR',            # Ошибка
        ]
      end

      def success_status_list
        @success_status_list ||= ['DONE']
      end
    end
  end
end
