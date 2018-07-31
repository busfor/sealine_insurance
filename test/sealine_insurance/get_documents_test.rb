# frozen_string_literal: true

require 'test_helper'

describe 'get documents' do
  let(:client) do
    SealineInsurance::Client.new(token: '0123456789abcdef')
  end

  it 'returns documents urls' do
    response =
      VCR.use_cassette('get_documents') do
        client.get_order(order_id: 7212)
      end

    assert_equal true, response.success?
    assert_equal false, response.error?

    assert_equal true, response.confirmed?
    assert_equal 7212, response.order_id
    assert_equal 'DONE', response.status
    assert_equal Money.new(70, 'RUB'), response.price
    assert_equal ['http://example.com/document.pdf'], response.documents
    assert_equal ['180H368S00008'], response.external_numbers
  end
end
