# frozen_string_literal: true

module SealineInsurance
  module Operations
    class CreateOrder < Base
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        config:,
        product_type:,
        product:,
        options: [],
        ticket_number:,
        ticket_price:,
        departure_datetime:,
        arrival_datetime:,
        insured_first_name:,
        insured_middle_name:,
        insured_last_name:,
        insured_birthday:,
        insurer_first_name:,
        insurer_middle_name:,
        insurer_last_name:
      )
        super(config: config)
        @product_type = product_type
        @product = product
        @options = options
        @ticket_number = ticket_number
        @ticket_price = ticket_price
        @departure_datetime = departure_datetime
        @arrival_datetime = arrival_datetime
        @insured_first_name = insured_first_name
        @insured_middle_name = insured_middle_name
        @insured_last_name = insured_last_name
        @insured_birthday = insured_birthday
        @insurer_first_name = insurer_first_name
        @insurer_middle_name = insurer_middle_name
        @insurer_last_name = insurer_last_name
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        raw_response = request.post('/order',
          product_type: @product_type,
          product: @product,
          options: @options,
          data: {
            ticket_number: @ticket_number.to_i,
            ticket_price: @ticket_price.to_i,
            departure: @departure_datetime.strftime('%Y-%m-%dT%H:%M'),
            arrival: @arrival_datetime.strftime('%Y-%m-%dT%H:%M'),
            insured: {
              first_name: @insured_first_name,
              middle_name: @insured_middle_name,
              last_name: @insured_last_name,
              birthday: @insured_birthday.strftime('%Y-%m-%d'),
            },
            insurer: {
              first_name: @insurer_first_name,
              middle_name: @insurer_middle_name,
              last_name: @insurer_last_name,
            },
          },
        )
        @response = Responses::Order.new(raw_response)
        @order_id = @response.order_id
      end

      def fetch_status!
        raw_response = request.get("/order/#{@order_id}")
        @response = Responses::Order.new(raw_response)
      end

      private

      def finished_status_list
        @finished_status_list ||= [
          'ERROR',          # Ошибка
          'NEED_PAYMENT',   # Требуется оплата
        ]
      end

      def success_status_list
        @success_status_list ||= ['NEED_PAYMENT']
      end
    end
  end
end
