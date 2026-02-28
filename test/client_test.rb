# frozen_string_literal: true

require "test_helper"

class AgentmailClientTest < Minitest::Test
  attr_reader :base_url, :client

  def setup
    @base_url = "https://mock.agentmail.test"
    @client = Agentmail::Client.new(api_key: "test", base_url: base_url)
  end

  def test_requires_api_key
    error = assert_raises(Agentmail::ConfigurationError) do
      Agentmail::Client.new(api_key: nil, base_url: base_url)
    end

    assert_match(/api key/i, error.message)
  end

  def test_supports_known_environments
    eu_client = Agentmail::Client.new(api_key: "abc", environment: :eu_prod)

    assert_equal "https://api.agentmail.eu", eu_client.base_url
  end

  def test_request_returns_parsed_response
    stub_request(:get, "#{base_url}/v0/inboxes")
      .with(headers: { "Authorization" => "Bearer test" })
      .to_return(status: 200, body: '{"inboxes":[]}', headers: { "Content-Type" => "application/json" })

    response = client.request(:get, "/v0/inboxes")

    assert response.success?
    assert_equal({ "inboxes" => [] }, response.body)
  end

  def test_request_raises_on_failure
    stub_request(:get, "#{base_url}/v0/inboxes/123")
      .to_return(status: 404, body: '{"error":"missing"}', headers: { "Content-Type" => "application/json" })

    error = assert_raises(Agentmail::Error) { client.request(:get, "v0/inboxes/123") }

    assert_equal 404, error.status
    assert_equal({ "error" => "missing" }, error.body)
  end

  def test_request_stringifies_params
    stub_request(:get, "#{base_url}/v0/threads")
      .with(query: { "limit" => "2" })
      .to_return(status: 200, body: '{"threads":[]}', headers: { "Content-Type" => "application/json" })

    client.request(:get, "/v0/threads", params: { limit: 2 })
  end

  def test_callable_api_key
    call_count = 0
    key_proc = -> { call_count += 1; "rotated-key" }
    callable_client = Agentmail::Client.new(api_key: key_proc, base_url: base_url)

    stub_request(:get, "#{base_url}/v0/inboxes")
      .with(headers: { "Authorization" => "Bearer rotated-key" })
      .to_return(status: 200, body: '{"inboxes":[]}', headers: { "Content-Type" => "application/json" })

    callable_client.request(:get, "/v0/inboxes")

    assert call_count > 0, "API key proc should have been called"
  end

  def test_unknown_environment_raises
    error = assert_raises(Agentmail::ConfigurationError) do
      Agentmail::Client.new(api_key: "test", environment: :nonexistent)
    end

    assert_match(/unknown environment/i, error.message)
  end

  def test_configuration_error_is_not_an_api_error
    refute_kind_of Agentmail::Error, Agentmail::ConfigurationError.new("bad config")
  end

  def test_request_rejects_absolute_url_as_path
    assert_raises(ArgumentError) { client.request(:get, "https://evil.example.com/steal") }
    assert_raises(ArgumentError) { client.request(:get, "http://evil.example.com/steal") }
  end
end
