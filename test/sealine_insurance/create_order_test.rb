# frozen_string_literal: true

require 'test_helper'

describe 'create order' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  let(:valid_params) do
    {
      product_type: 'transport',
      product: 'vsk_trans',
      ticket_number: 12345678,
      ticket_price: Money.new(100, 'RUB'),
      departure_datetime: Time.new(2018, 8, 1, 10, 0, 0),
      arrival_datetime: Time.new(2018, 8, 1, 18, 0, 0),
      insured_first_name: 'Иван',
      insured_last_name: 'Иванов',
      insured_birthday: Date.new(1985, 1, 15),
      insurer_first_name: 'Петр',
      insurer_last_name: 'Петров',
    }
  end

  it 'creates order and returns result' do
    VCR.use_cassette('create_order_and_fetch_reslult') do
      operation = client.create_order(**valid_params)
      assert_equal false, operation.finished?

      response = operation.response
      assert_equal 7311, response.order_id
      assert_equal 'IN_PROGRESS', response.status

      operation.fetch_result!
      assert_equal true, operation.finished?
      assert_equal true, operation.success?

      response = operation.response
      assert_equal 7311, response.order_id
      assert_equal 'NEED_PAYMENT', response.status
      assert_equal Money.new(70, 'RUB'), response.price
    end
  end

  describe 'params validation errors' do
    it 'returns error with invalid product' do
      operation =
        VCR.use_cassette('create_order_with_invalid_product') do
          client.create_order(**valid_params.merge(product: 'invalid'))
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      response = operation.response
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        'product: Недопустимый первичный ключ "invalid" - объект не существует.',
        response.error_message,
      )
    end

    it 'returns error with invalid arrival_datetime' do
      operation =
        VCR.use_cassette('create_order_with_invalid_arrival_datetime') do
          client.create_order(
            **valid_params.merge(
              arrival_datetime: Time.new(2018, 8, 1, 9, 0, 0),
            ),
          )
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      response = operation.response
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        'data.arrival: Не может быть меньше даты trip.departure.date',
        response.error_message,
      )
    end

    it 'returns error with empty insured_first_name' do
      operation =
        VCR.use_cassette('create_order_with_empty_insured_first_name') do
          client.create_order(**valid_params.merge(insured_first_name: nil))
        end

      assert_equal true, operation.finished?
      assert_equal false, operation.success?

      response = operation.response
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        "data.insured.first_name: Ошибка валидации схемы. Сообщение: None is not of type u'string'",
        response.error_message,
      )
    end
  end
end
