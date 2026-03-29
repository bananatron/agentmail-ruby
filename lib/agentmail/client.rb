# frozen_string_literal: true

require "json"
require "faraday"

require_relative "error"
require_relative "response"
require_relative "resources/inboxes"
require_relative "resources/pods"
require_relative "resources/threads"

module Agentmail
  class Client
    DEFAULT_TIMEOUT = 60
    DEFAULT_OPEN_TIMEOUT = 5
    DEFAULT_ENVIRONMENTS = {
      prod: "https://api.agentmail.to",
      prod_x_402: "https://x402.api.agentmail.to",
      prod_mpp: "https://mpp.api.agentmail.to",
      eu_prod: "https://api.agentmail.eu"
    }.freeze

    attr_reader :base_url, :timeout, :open_timeout

    def initialize(
      api_key: ENV["AGENTMAIL_API_KEY"],
      base_url: nil,
      environment: :prod,
      timeout: DEFAULT_TIMEOUT,
      open_timeout: DEFAULT_OPEN_TIMEOUT,
      adapter: Faraday.default_adapter,
      user_agent: nil,
      extra_headers: {},
      logger: nil
    )
      @api_key = api_key
      @base_url = (base_url || resolve_environment(environment)).to_s.sub(%r{\/+\z}, "")
      @timeout = timeout || DEFAULT_TIMEOUT
      @open_timeout = open_timeout || DEFAULT_OPEN_TIMEOUT
      @user_agent = user_agent || default_user_agent
      @extra_headers = extra_headers
      @adapter = adapter
      @logger = logger
      validate_api_key!
    end

    def inboxes
      @inboxes ||= Resources::Inboxes.new(self)
    end

    def pods
      @pods ||= Resources::Pods.new(self)
    end

    def threads
      @threads ||= Resources::Threads.new(self)
    end

    def request(method, path, params: nil, body: nil, headers: {}, timeout: nil)
      response = connection.run_request(
        method.to_sym,
        normalize_path(path),
        encoded_body(body),
        build_headers(body, headers)
      ) do |req|
        req.params.update(stringify_keys(params)) if params
        req.options.timeout = timeout || @timeout if req.options.respond_to?(:timeout=)
        req.options.open_timeout = @open_timeout if @open_timeout && req.options.respond_to?(:open_timeout=)
      end

      parsed_body = parse_body(response)
      wrapped = Response.new(status: response.status, headers: response.headers.to_h, body: parsed_body)
      return wrapped if wrapped.success?

      raise Error.new(
        "AgentMail request failed with status #{response.status}",
        status: response.status,
        headers: response.headers.to_h,
        body: parsed_body
      )
    end

    private

    def validate_api_key!
      key = api_key_value
      raise ConfigurationError, "An AgentMail API key is required" if key.nil? || key.empty?
    end

    def api_key_value
      value = @api_key.respond_to?(:call) ? @api_key.call : @api_key
      value&.to_s&.strip
    end

    def build_headers(body, overrides)
      headers = {
        "Authorization" => "Bearer #{api_key_value}",
        "User-Agent" => @user_agent,
        "Accept" => "application/json"
      }.merge(@extra_headers).merge(overrides.transform_keys(&:to_s))
      headers["Content-Type"] = "application/json" if body && !headers.key?("Content-Type")
      headers
    end

    def connection
      @connection ||= Faraday.new(url: @base_url) do |faraday|
        faraday.response :logger, @logger if @logger
        faraday.adapter @adapter
      end
    end

    def encoded_body(body)
      return nil if body.nil?
      return body if body.is_a?(String)

      JSON.generate(body)
    end

    def parse_body(response)
      return nil if response.body.nil? || response.body.empty?

      content_type = Array(response.headers["content-type"] || response.headers["Content-Type"]).first.to_s
      if content_type.include?("json")
        JSON.parse(response.body)
      else
        response.body
      end
    rescue JSON::ParserError
      response.body
    end

    def stringify_keys(hash)
      hash.each_with_object({}) do |(key, value), acc|
        acc[key.to_s] = value
      end
    end

    def normalize_path(path)
      if path.to_s.start_with?("http://", "https://")
        raise ArgumentError, "path must be a relative path, not a full URL"
      end

      path.to_s.start_with?("/") ? path.to_s : "/#{path}"
    end

    def resolve_environment(env)
      DEFAULT_ENVIRONMENTS.fetch(env.to_sym) do
        raise ConfigurationError, "Unknown environment #{env.inspect}"
      end
    end

    def default_user_agent
      "agentmail-ruby/#{Agentmail::VERSION}"
    end
  end
end
