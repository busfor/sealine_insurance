# frozen_string_literal: true

require 'test_helper'

describe 'create payment' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  it 'creates payment' do
    response =
      VCR.use_cassette('create_payment') do
        client.create_payment(order_id: 7212)
      end

    assert_equal true, response.success?
    assert_equal false, response.error?

    assert_equal 7212, response.order_id
    assert_equal 3997, response.payment_id
    assert_equal 'IN_PROGRESS', response.status
  end

  it 'returns error if payment already exists' do
    response =
      VCR.use_cassette('create_payment_already_exists') do
        client.create_payment(order_id: 7212)
      end

    assert_equal false, response.success?
    assert_equal true, response.error?

    assert_equal 'conflict', response.error_code
    assert_equal(
      'Некорректный статус заказа для проведения оплаты: Создан',
      response.error_message,
    )
  end

  it 'returns error for invalid order_id' do
    response =
      VCR.use_cassette('create_payment_invalid_order_id') do
        client.create_payment(order_id: 9999)
      end

    assert_equal false, response.success?
    assert_equal true, response.error?

    assert_equal 'invalid_params', response.error_code
    assert_equal(
      'order: Недопустимый первичный ключ "9999" - объект не существует.',
      response.error_message,
    )
  end
end
