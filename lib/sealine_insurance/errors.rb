# frozen_string_literal: true

module SealineInsurance
  class Error < StandardError
  end

  class RequestError < Error
  end

  class InvalidResponse < Error
  end
end
