# frozen_string_literal: true

module Agentmail
  # Generic error raised when the API responds with a non-success status or when
  # the client is configured incorrectly.
  class Error < StandardError
    attr_reader :status, :headers, :body

    def initialize(message = nil, status: nil, headers: {}, body: nil)
      super(message || "AgentMail request failed")
      @status = status
      @headers = headers || {}
      @body = body
    end
  end

  class ConfigurationError < StandardError; end
end
