# frozen_string_literal: true

require 'faraday'
require 'json'
require 'money'

require 'sealine_insurance/version'
require 'sealine_insurance/errors'
require 'sealine_insurance/config'
require 'sealine_insurance/client'
require 'sealine_insurance/request'
require 'sealine_insurance/operations/base'
require 'sealine_insurance/operations/calculate'
require 'sealine_insurance/operations/create_order'
require 'sealine_insurance/operations/create_payment'
require 'sealine_insurance/operations/cancel_order'
require 'sealine_insurance/responses/base'
require 'sealine_insurance/responses/calculate'
require 'sealine_insurance/responses/order'
require 'sealine_insurance/responses/payment'

module SealineInsurance
  DEFAULT_CURRENCY = 'RUB'
end
