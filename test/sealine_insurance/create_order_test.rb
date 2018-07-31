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

  describe 'base flow' do
    it 'creates order' do
      response =
        VCR.use_cassette('create_order') do
          client.create_order(**valid_params)
        end

      assert_equal 7212, response.order_id
      assert_equal 'IN_PROGRESS', response.status

      assert_equal true, response.success?
      assert_equal false, response.error?

      assert_equal false, response.created?
    end

    it 'returns success result' do
      response =
        VCR.use_cassette('create_order_status') do
          client.get_order(order_id: 7212)
        end

      assert_equal 7212, response.order_id
      assert_equal 'NEED_PAYMENT', response.status

      assert_equal true, response.success?
      assert_equal false, response.error?

      assert_equal true, response.created?
    end
  end

  describe 'params validation errors' do
    it 'returns error with invalid product' do
      response =
        VCR.use_cassette('create_order_with_invalid_product') do
          client.create_order(**valid_params.merge(product: 'invalid'))
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        'product: Недопустимый первичный ключ "invalid" - объект не существует.',
        response.error_message,
      )
    end

    it 'returns error with invalid arrival_datetime' do
      response =
        VCR.use_cassette('create_order_with_invalid_arrival_datetime') do
          client.create_order(
            **valid_params.merge(
              arrival_datetime: Time.new(2018, 8, 1, 9, 0, 0),
            ),
          )
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        'data.arrival: Не может быть меньше даты trip.departure.date',
        response.error_message,
      )
    end

    it 'returns error with empty insured_first_name' do
      response =
        VCR.use_cassette('create_order_with_empty_insured_first_name') do
          client.create_order(**valid_params.merge(insured_first_name: nil))
        end

      assert_equal false, response.success?
      assert_equal true, response.error?
      assert_equal 'invalid_params', response.error_code
      assert_equal(
        "data.insured.first_name: Ошибка валидации схемы. Сообщение: None is not of type u'string'",
        response.error_message,
      )
    end
  end
end
