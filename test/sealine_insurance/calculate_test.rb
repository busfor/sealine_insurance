# frozen_string_literal: true

require 'test_helper'

describe 'calculate insurance price' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  describe 'base flow' do
    it 'creates calculation' do
      response =
        VCR.use_cassette('calculate') do
          client.calculate(
            product_type: 'transport',
            products: %w[vsk_trans],
            ticket_price: Money.new(100, 'RUB'),
          )
        end

      assert_equal 89234, response.request_id
      assert_equal 'IN_PROGRESS', response.status

      assert_equal true, response.success?
      assert_equal false, response.error?

      assert_equal false, response.calculated?
      assert_nil response.price
    end

    it 'returns success result' do
      response =
        VCR.use_cassette('calculate_status') do
          client.calculate_status(
            request_id: 89234,
          )
        end

      assert_equal 89234, response.request_id
      assert_equal 'DONE', response.status

      assert_equal true, response.success?
      assert_equal false, response.error?

      assert_equal true, response.calculated?
      assert_equal Money.new(70, 'RUB'), response.price
    end
  end

  describe 'params validation errors' do
    it 'returns error with invalid product_type' do
      response =
        VCR.use_cassette('calculate_with_invalid_product_type') do
          client.calculate(
            product_type: 'invalid',
            products: %w[vsk_trans],
            ticket_price: Money.new(100, 'RUB'),
          )
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        'product_type: Некорректное значение. Используйте `code` из /classifiers/product-type/',
        response.error_message,
      )
    end

    it 'returns error with invalid products' do
      response =
        VCR.use_cassette('calculate_with_invalid_product') do
          client.calculate(
            product_type: 'transport',
            products: %w[invalid],
            ticket_price: Money.new(100, 'RUB'),
          )
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal 'products: Продукт (invalid) не доступен', response.error_message
    end

    it 'returns error with invalid options' do
      response =
        VCR.use_cassette('calculate_with_invalid_options') do
          client.calculate(
            product_type: 'transport',
            products: %w[vsk_trans],
            ticket_price: Money.new(100, 'RUB'),
            options: ['invalid'],
          )
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal "options: Выбраны недопустимые опции: ['invalid']", response.error_message
    end
  end
end
