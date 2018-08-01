# frozen_string_literal: true

require 'test_helper'

describe 'errors' do
  it 'returns error response for invalid json' do
    client = SealineInsurance::Client.new(token: '0123456789abcdef')

    response =
      VCR.use_cassette('errors/invalid_json_body') do
        client.product_types
      end

    assert_equal false, response.success?
    assert_equal true, response.error?
    assert_equal 'invalid_response', response.error_code
    assert_equal 'Invalid JSON', response.error_message
  end

  it 'returns error response for invalid token' do
    client = SealineInsurance::Client.new(token: 'invalid')

    response =
      VCR.use_cassette('errors/invalid_token') do
        client.product_types
      end

    assert_equal false, response.success?
    assert_equal true, response.error?
    assert_equal 'unauthorized', response.error_code
    assert_equal 'Недопустимый токен.', response.error_message
  end
end
