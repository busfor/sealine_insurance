# frozen_string_literal: true

require 'test_helper'

describe 'calculate insurance price' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  it 'calculates price and returns result' do
    VCR.use_cassette('calculate_and_fetch_result') do
      operation = client.calculate(
        product_type: 'transport',
        products: %w[vsk_trans],
        ticket_price: Money.new(100, 'RUB'),
      )
      assert_equal false, operation.finished?

      response = operation.response
      assert_equal 'IN_PROGRESS', response.status

      operation.fetch_status!
      assert_equal true, operation.finished?
      assert_equal true, operation.success?

      result = operation.result
      assert_equal 'DONE', result.status
      assert_equal Money.new(70_00, 'RUB'), result.price
      assert_equal Money.new(200_000_00, 'RUB'), result.coverage
    end
  end

  describe 'params validation errors' do
    it 'returns error with invalid product_type' do
      operation =
        VCR.use_cassette('calculate_with_invalid_product_type') do
          client.calculate(
            product_type: 'invalid',
            products: %w[vsk_trans],
            ticket_price: Money.new(100, 'RUB'),
          )
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      result = operation.result
      assert_equal 'invalid_params', result.error_code
      assert_equal(
        'product_type: Некорректное значение. Используйте `code` из /classifiers/product-type/',
        result.error_message,
      )
    end

    it 'returns error with invalid products' do
      operation =
        VCR.use_cassette('calculate_with_invalid_product') do
          client.calculate(
            product_type: 'transport',
            products: %w[invalid],
            ticket_price: Money.new(100, 'RUB'),
          )
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      result = operation.result
      assert_equal 'invalid_params', result.error_code
      assert_equal 'products: Продукт (invalid) не доступен', result.error_message
    end

    it 'returns error with invalid options' do
      operation =
        VCR.use_cassette('calculate_with_invalid_options') do
          client.calculate(
            product_type: 'transport',
            products: %w[vsk_trans],
            ticket_price: Money.new(100, 'RUB'),
            options: ['invalid'],
          )
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      result = operation.result
      assert_equal 'invalid_params', result.error_code
      assert_equal "options: Выбраны недопустимые опции: ['invalid']", result.error_message
    end
  end
end
