# frozen_string_literal: true

require "test_helper"

class PodsResourceTest < Minitest::Test
  attr_reader :base_url, :resource

  def setup
    @base_url = "https://mock.agentmail.test"
    client = Agentmail::Client.new(api_key: "test", base_url: base_url)
    @resource = client.pods
  end

  def test_list_returns_pods
    stub_request(:get, "#{base_url}/v0/pods")
      .to_return(status: 200, body: '{"pods":[{"id":"pod_abc"}]}', headers: { "Content-Type" => "application/json" })

    response = resource.list

    assert_equal({ "pods" => [{ "id" => "pod_abc" }] }, response)
  end

  def test_retrieve_fetches_pod
    stub_request(:get, "#{base_url}/v0/pods/pod_123")
      .to_return(status: 200, body: '{"id":"pod_123"}', headers: { "Content-Type" => "application/json" })

    assert_equal({ "id" => "pod_123" }, resource.retrieve("pod_123"))
  end

  def test_create_posts_payload
    stub = stub_request(:post, "#{base_url}/v0/pods")
             .with(body: { client_id: "client_1" }.to_json)
             .to_return(status: 200, body: '{"id":"pod_new"}', headers: { "Content-Type" => "application/json" })

    response = resource.create(client_id: "client_1")

    assert_requested(stub)
    assert_equal({ "id" => "pod_new" }, response)
  end

  def test_delete_calls_endpoint
    stub = stub_request(:delete, "#{base_url}/v0/pods/pod_123")
             .to_return(status: 200, body: "", headers: {})

    resource.delete("pod_123")

    assert_requested(stub)
  end

  def test_list_inboxes_returns_inboxes
    stub_request(:get, "#{base_url}/v0/pods/pod_123/inboxes")
      .to_return(status: 200, body: '{"inboxes":[{"id":"inbox_1"}]}', headers: { "Content-Type" => "application/json" })

    response = resource.list_inboxes("pod_123")

    assert_equal({ "inboxes" => [{ "id" => "inbox_1" }] }, response)
  end

  def test_create_inbox_posts_payload
    stub = stub_request(:post, "#{base_url}/v0/pods/pod_123/inboxes")
             .with(body: { display_name: "Support" }.to_json)
             .to_return(status: 200, body: '{"id":"inbox_new"}', headers: { "Content-Type" => "application/json" })

    response = resource.create_inbox("pod_123", display_name: "Support")

    assert_requested(stub)
    assert_equal({ "id" => "inbox_new" }, response)
  end

  def test_delete_inbox_calls_endpoint
    stub = stub_request(:delete, "#{base_url}/v0/pods/pod_123/inboxes/inbox_456")
             .to_return(status: 200, body: "", headers: {})

    resource.delete_inbox("pod_123", "inbox_456")

    assert_requested(stub)
  end
end
