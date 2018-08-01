# frozen_string_literal: true

module SealineInsurance
  module Operations
    class Calculate < Base
      FINISHED_STATES = [
        'DONE',             # Выполнено
        'DONE_WITH_ERRORS', # Выполнено с ошибками
        'ERROR',            # Ошибка
      ].freeze

      SUCCESS_STATES = [
        'DONE',             # Выполнено
      ].freeze

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

      def finished?
        FINISHED_STATES.include?(response.status) || response.error?
      end

      def success?
        SUCCESS_STATES.include?(response.status)
      end
    end
  end
end
