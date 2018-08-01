# frozen_string_literal: true

require 'test_helper'

describe 'create payment' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  it 'creates payment and returns result' do
    VCR.use_cassette('create_payment_and_fetch_result') do
      operation = client.create_payment(order_id: 7311)
      assert_equal false, operation.finished?

      response = operation.response
      assert_equal 'IN_PROGRESS', response.status

      operation.fetch_result!
      assert_equal true, operation.finished?
      assert_equal true, operation.success?

      result = operation.result
      assert_equal 'DONE', result.status
      assert_equal Money.new(70, 'RUB'), result.price
      assert_equal ['180H368S00014'], result.external_numbers
      assert_equal(
        ['https://dev.sealine.ru/media/contractor-orders/2018/07/31/vsk_int7187.pdf?t=eyJ0b2tlbiI6IjYxN2FiMGEwZTBkMTJlMjQ4YTliNTVmYWVmYmJmNzcwMGVlNjhlNzQiLCJpZCI6NzE4N30%3A1fkYSu%3AxMmFmI1wTaCzShewVLnSCX8Bx8k'],
        result.documents,
      )
    end
  end

  it 'returns error if payment already exists' do
    operation =
      VCR.use_cassette('create_payment_already_exists') do
        client.create_payment(order_id: 7212)
      end

    assert_equal true, operation.finished?
    assert_equal false, operation.success?

    result = operation.result
    assert_equal 'conflict', result.error_code
    assert_equal(
      'Некорректный статус заказа для проведения оплаты: Создан',
      result.error_message,
    )
  end

  it 'returns error for invalid order_id' do
    operation =
      VCR.use_cassette('create_payment_invalid_order_id') do
        client.create_payment(order_id: 9999)
      end

    assert_equal true, operation.finished?
    assert_equal false, operation.success?

    result = operation.result
    assert_equal 'invalid_params', result.error_code
    assert_equal(
      'order: Недопустимый первичный ключ "9999" - объект не существует.',
      result.error_message,
    )
  end
end
