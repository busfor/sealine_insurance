# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sealine_insurance'

require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  config.before_record do |item|
    item.response.body.force_encoding('UTF-8')
  end
end

module VCR
  # use_cassette проверяет корректность отправляемых запросов только на уровне URL и HTTP-метода.
  # use_strict_cassette также проверяет корректность тела запроса.
  # Подробнее: https://github.com/vcr/vcr/blob/master/features/request_matching/README.md
  def self.use_strict_cassette(name, options = {}, &block)
    options[:match_requests_on] ||= [:method, :uri, :body]
    use_cassette(name, options, &block)
  end
end
