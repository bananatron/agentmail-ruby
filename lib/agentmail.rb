# frozen_string_literal: true

require_relative "agentmail/version"
require_relative "agentmail/error"
require_relative "agentmail/response"
require_relative "agentmail/client"

module Agentmail
  def self.new(...)
    Client.new(...)
  end
end
