# frozen_string_literal: true

require 'faraday'
require 'json'
require 'money'

require 'sealine_insurance/version'
require 'sealine_insurance/errors'
require 'sealine_insurance/config'
require 'sealine_insurance/client'
require 'sealine_insurance/request'
require 'sealine_insurance/base_response'
require 'sealine_insurance/calculate_response'
require 'sealine_insurance/order_response'

module SealineInsurance
  DEFAULT_CURRENCY = 'RUB'
end
