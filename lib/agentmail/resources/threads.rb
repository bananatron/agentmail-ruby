# frozen_string_literal: true

require_relative "base_resource"

module Agentmail
  module Resources
    class Threads < BaseResource
      def list(params = {})
        request(:get, "/v0/threads", params: params).body
      end

      def retrieve(thread_id)
        request(:get, thread_path(thread_id)).body
      end
      alias get retrieve

      def attachment(thread_id, attachment_id)
        request(:get, "#{thread_path(thread_id)}/attachments/#{attachment_id}").body
      end

      private

      def thread_path(thread_id)
        "/v0/threads/#{thread_id}"
      end
    end
  end
end
