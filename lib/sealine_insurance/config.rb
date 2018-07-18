# frozen_string_literal: true

module SealineInsurance
  class Config
    DEFAULT_HOST = 'dev.sealine.ru'

    attr_reader :host
    attr_reader :token
    attr_reader :timeout
    attr_reader :open_timeout
    attr_reader :logger

    def initialize(host: DEFAULT_HOST, token:, timeout: nil, open_timeout: nil, logger: nil)
      @host = host
      @token = token
      @timeout = timeout
      @open_timeout = open_timeout
      @logger = logger
    end

    def base_url
      "https://#{host}/api/v1"
    end
  end
end
