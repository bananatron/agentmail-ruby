# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"

require "agentmail"

WebMock.disable_net_connect!(allow_localhost: true)
