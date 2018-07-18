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
      request.get("/classifiers/#{path}")
    end

    def search_products(product_type:, options: [])
      request.post('/search',
        product_type: product_type,
        options: options,
      )
    end

    private

    def request
      @request ||= Request.new(config: config)
    end
  end
end
