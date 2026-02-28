# frozen_string_literal: true

require "test_helper"

class InboxesResourceTest < Minitest::Test
  attr_reader :base_url, :resource

  def setup
    @base_url = "https://mock.agentmail.test"
    client = Agentmail::Client.new(api_key: "test", base_url: base_url)
    @resource = client.inboxes
  end

  def test_list_returns_inboxes
    stub_request(:get, "#{base_url}/v0/inboxes")
      .to_return(status: 200, body: '{"inboxes":[{"id":"abc"}]}', headers: { "Content-Type" => "application/json" })

    response = resource.list

    assert_equal({ "inboxes" => [{ "id" => "abc" }] }, response)
  end

  def test_retrieve_fetches_inbox
    stub_request(:get, "#{base_url}/v0/inboxes/inbox_123")
      .to_return(status: 200, body: '{"id":"inbox_123"}', headers: { "Content-Type" => "application/json" })

    assert_equal({ "id" => "inbox_123" }, resource.retrieve("inbox_123"))
  end

  def test_create_posts_payload
    stub = stub_request(:post, "#{base_url}/v0/inboxes")
             .with(body: { display_name: "Support" }.to_json)
             .to_return(status: 200, body: '{"id":"new"}', headers: { "Content-Type" => "application/json" })

    response = resource.create(display_name: "Support")

    assert_requested(stub)
    assert_equal({ "id" => "new" }, response)
  end

  def test_update_patches_inbox
    stub = stub_request(:patch, "#{base_url}/v0/inboxes/inbox_123")
             .with(body: { display_name: "New name" }.to_json)
             .to_return(status: 200, body: '{"id":"inbox_123","display_name":"New name"}', headers: { "Content-Type" => "application/json" })

    response = resource.update("inbox_123", display_name: "New name")

    assert_requested(stub)
    assert_equal("New name", response["display_name"])
  end

  def test_delete_calls_endpoint
    stub = stub_request(:delete, "#{base_url}/v0/inboxes/inbox_123")
             .to_return(status: 200, body: "", headers: {})

    resource.delete("inbox_123")

    assert_requested(stub)
  end
end
