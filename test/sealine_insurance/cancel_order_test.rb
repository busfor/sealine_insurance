# frozen_string_literal: true

require 'test_helper'

describe 'cancel order' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  it 'returns result after first request' do
    operation =
      VCR.use_cassette('cancel_order_single_request') do
        client.cancel_order(order_id: 7212)
      end

    assert_equal true, operation.finished?
    assert_equal true, operation.success?

    result = operation.result
    assert_equal 7212, result.order_id
    assert_equal 'CANCELLED', result.status
  end

  it 'returns result after multiple requests' do
    VCR.use_cassette('cancel_order_multiple_requests') do
      operation = client.cancel_order(order_id: 7212)

      assert_equal false, operation.finished?
      assert_equal false, operation.success?
      assert_equal 7212, operation.response.order_id
      assert_equal 'CANCEL_IN_PROGRESS', operation.response.status

      operation.fetch_result!

      assert_equal true, operation.finished?
      assert_equal true, operation.success?
      assert_equal 7212, operation.result.order_id
      assert_equal 'CANCELLED', operation.result.status
    end
  end
end
