# frozen_string_literal: true

module SealineInsurance
  class Client
    attr_reader :config

    def initialize(**args)
      @config = Config.new(**args)
    end

    def product_types
      classifiers(path: 'product-type')
    end

    def product_type(id:)
      classifiers(path: "product-type/#{id}")
    end

    def products
      classifiers(path: 'product')
    end

    def component_groups
      classifiers(path: 'product/component-group')
    end

    def calculate_status_list
      classifiers(path: 'status/calculate-product')
    end

    def order_status_list
      classifiers(path: 'status/order')
    end

    def payment_status_list
      classifiers(path: 'status/payment')
    end

    def classifiers(path:)
      response = request.get("/classifiers/#{path}")
      BaseResponse.new(response)
    end

    def search_products(product_type:, options: [])
      response = request.post('/search',
        product_type: product_type,
        options: options,
      )
      BaseResponse.new(response)
    end

    def calculate(product_type:, products:, ticket_price:, options: [])
      response = request.post('/calculate-product',
        product_type: product_type,
        products: products,
        options: options,
        data: {
          ticket_price: ticket_price.to_i,
        },
      )
      CalculateResponse.new(response)
    end

    def calculate_status(request_id:)
      response = request.get("/calculate-product/#{request_id}")
      CalculateResponse.new(response)
    end

    # rubocop:disable Metrics/ParameterLists
    def create_order(
      product_type:,
      product:,
      options: [],
      ticket_number:,
      ticket_price:,
      departure_datetime:,
      arrival_datetime:,
      insured_first_name:,
      insured_last_name:,
      insured_birthday:,
      insurer_first_name:,
      insurer_last_name:
    )
      response = request.post('/order',
        product_type: product_type,
        product: product,
        options: options,
        data: {
          ticket_number: ticket_number.to_i,
          ticket_price: ticket_price.to_i,
          departure: departure_datetime.strftime('%Y-%m-%dT%H:%M'),
          arrival: arrival_datetime.strftime('%Y-%m-%dT%H:%M'),
          insured: {
            first_name: insured_first_name,
            last_name: insured_last_name,
            birthday: insured_birthday.strftime('%Y-%m-%d'),
          },
          insurer: {
            first_name: insurer_first_name,
            last_name: insurer_last_name,
          },
        },
      )
      OrderResponse.new(response)
    end
    # rubocop:enable Metrics/ParameterLists

    def get_order(order_id:)
      response = request.get("/order/#{order_id}")
      OrderResponse.new(response)
    end

    private

    def request
      @request ||= Request.new(config: config)
    end
  end
end
