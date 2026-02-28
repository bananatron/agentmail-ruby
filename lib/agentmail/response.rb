# frozen_string_literal: true

module Agentmail
  # Wraps the raw Faraday response to provide a predictable surface.
  class Response
    attr_reader :status, :headers, :body

    def initialize(status:, headers:, body:)
      @status = status
      @headers = headers
      @body = body
    end

    def success?
      status.to_i >= 200 && status.to_i < 300
    end
  end
end
