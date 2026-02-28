# frozen_string_literal: true

require "test_helper"

class AgentmailTest < Minitest::Test
  def test_has_version_number
    refute_nil Agentmail::VERSION
  end

  def test_new_returns_client
    client = Agentmail.new(api_key: "test")

    assert_instance_of Agentmail::Client, client
  end
end
