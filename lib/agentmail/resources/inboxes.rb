# frozen_string_literal: true

require_relative "base_resource"

module Agentmail
  module Resources
    class Inboxes < BaseResource
      def list(params = {})
        request(:get, "/v0/inboxes", params: params).body
      end

      def retrieve(inbox_id)
        request(:get, inbox_path(inbox_id)).body
      end
      alias get retrieve

      def create(attributes = {})
        request(:post, "/v0/inboxes", body: attributes).body
      end

      def update(inbox_id, attributes = {})
        request(:patch, inbox_path(inbox_id), body: attributes).body
      end

      def delete(inbox_id)
        request(:delete, inbox_path(inbox_id)).body
      end

      private

      def inbox_path(inbox_id)
        "/v0/inboxes/#{inbox_id}"
      end
    end
  end
end
