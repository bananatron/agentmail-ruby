# frozen_string_literal: true

module Agentmail
  module Resources
    class BaseResource
      def initialize(client)
        @client = client
      end

      private

      attr_reader :client

      def request(...)
        client.request(...)
      end
    end
  end
end
