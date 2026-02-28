# frozen_string_literal: true

require "test_helper"

class ThreadsResourceTest < Minitest::Test
  attr_reader :base_url, :resource

  def setup
    @base_url = "https://mock.agentmail.test"
    client = Agentmail::Client.new(api_key: "test", base_url: base_url)
    @resource = client.threads
  end

  def test_list_supports_filters
    stub = stub_request(:get, "#{base_url}/v0/threads")
             .with(query: { "limit" => "5" })
             .to_return(status: 200, body: '{"threads":[]}', headers: { "Content-Type" => "application/json" })

    resource.list(limit: 5)

    assert_requested(stub)
  end

  def test_retrieve_gets_thread
    stub_request(:get, "#{base_url}/v0/threads/thread_123")
      .to_return(status: 200, body: '{"id":"thread_123"}', headers: { "Content-Type" => "application/json" })

    assert_equal({ "id" => "thread_123" }, resource.retrieve("thread_123"))
  end

  def test_attachment_fetches_payload
    stub_request(:get, "#{base_url}/v0/threads/thread_123/attachments/att_1")
      .to_return(status: 200, body: '{"id":"att_1"}', headers: { "Content-Type" => "application/json" })

    assert_equal({ "id" => "att_1" }, resource.attachment("thread_123", "att_1"))
  end
end
