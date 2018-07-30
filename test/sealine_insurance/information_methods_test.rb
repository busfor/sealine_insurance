# frozen_string_literal: true

require 'test_helper'

describe 'information methods' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  describe 'product_types list' do
    it 'returns raw response' do
      response =
        VCR.use_cassette('product_types') do
          client.product_types
        end

      product_types = response.raw_body['objects'].map { |item| item['code'] }

      assert_equal true, response.success?
      assert_equal %w[transport], product_types
    end
  end

  describe 'search products' do
    it 'returns raw response' do
      response =
        VCR.use_cassette('search_products') do
          client.search_products(product_type: 'transport')
        end

      product_ids =
        response.raw_body['results']
          .map { |contractor| contractor['contractor_products'] }
          .flatten
          .map { |product| product['id'] }

      assert_equal true, response.success?
      assert_equal %w[vsk_trans_bus vsk_trans], product_ids
    end
  end
end
