# frozen_string_literal: true

require_relative "base_resource"

module Agentmail
  module Resources
    class Pods < BaseResource
      def list(params = {})
        request(:get, "/v0/pods", params: params).body
      end

      def retrieve(pod_id)
        request(:get, pod_path(pod_id)).body
      end
      alias get retrieve

      def create(attributes = {})
        request(:post, "/v0/pods", body: attributes).body
      end

      def delete(pod_id)
        request(:delete, pod_path(pod_id)).body
      end

      # Nested inbox endpoints

      def list_inboxes(pod_id, params = {})
        request(:get, "#{pod_path(pod_id)}/inboxes", params: params).body
      end

      def create_inbox(pod_id, attributes = {})
        request(:post, "#{pod_path(pod_id)}/inboxes", body: attributes).body
      end

      def delete_inbox(pod_id, inbox_id)
        request(:delete, "#{pod_path(pod_id)}/inboxes/#{inbox_id}").body
      end

      private

      def pod_path(pod_id)
        "/v0/pods/#{pod_id}"
      end
    end
  end
end
