# frozen_string_literal: true

module SealineInsurance
  class Client
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
      Responses::Base.new(response)
    end

    def search_products(product_type:, options: [])
      response = request.post('/search',
        product_type: product_type,
        options: options,
      )
      Responses::Base.new(response)
    end

    def calculate(**args)
      Operations::Calculate.new(config: @config, **args).tap(&:call)
    end

    def create_order(**args)
      Operations::CreateOrder.new(config: @config, **args).tap(&:call)
    end

    def get_order(order_id:)
      raw_response = request.get("/order/#{order_id}")
      Responses::Order.new(raw_response)
    end

    def create_payment(**args)
      Operations::CreatePayment.new(config: @config, **args).tap(&:call)
    end

    def cancel_order(**args)
      Operations::CancelOrder.new(config: @config, **args).tap(&:call)
    end

    private

    def request
      @request ||= Request.new(config: @config)
    end
  end
end
