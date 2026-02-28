# Agentmail Ruby Client

This is a lightweight Ruby wrapper for the [AgentMail](https://agentmail.to/) API inspired by the official [Python SDK](https://github.com/agentmail-to/agentmail-python). It focuses on the core HTTP plumbing and provides a small helper surface around the most common endpoints, while keeping extensibility simple via a generic request method.

## Installation

The gem has not been published yet, so install it straight from the repository:

```ruby
gem "agentmail", github: "agentmail-to/agentmail-ruby"
```

Run `bundle install` after updating your `Gemfile`.

## Usage

```ruby
require "agentmail"

client = Agentmail::Client.new(api_key: ENV.fetch("AGENTMAIL_API_KEY"))

# List inboxes
client.inboxes.list

# Create an inbox
client.inboxes.create(display_name: "Support")

# Fetch a thread with filters similar to the Python SDK
client.threads.list(limit: 25, include_spam: false)

# Use the low-level request helper for endpoints that don't have a helper yet
client.request(:post, "/v0/inboxes/inbox_123/drafts", body: { subject: "Hello" })
```

### Configuration

```ruby
client = Agentmail::Client.new(
  api_key: -> { ENV["AGENTMAIL_API_KEY"] }, # lazily evaluated for rotations
  environment: :eu_prod,                    # or :prod, :prod_x_402, :prod_mpp
  timeout: 30,
  open_timeout: 2,
  extra_headers: { "X-Debug" => "1" }
)
```

The `environment` option maps to the same host list used by the Python SDK. You can also override `base_url` entirely if you are testing against a mock server.

## Development

```bash
bin/setup
bundle exec rake test
```

The codebase deliberately avoids code generation so a contributor can read through the API surface. If you need an endpoint that is not wrapped yet, either open a PR or call it directly via `Client#request`.

## Manual Smoke Test

1. Copy `.env.example` to `.env` and add your `AGENTMAIL_API_KEY`. Optionally set `SMOKE_TEST_RECIPIENT` if you want to exercise outbound email delivery.
2. Set `SMOKE_TEST_SEND_EMAIL=true` if you want the script to send a short message to `SMOKE_TEST_RECIPIENT`; otherwise the run is read-only.
3. Run:

   ```bash
   bin/smoke_test
   ```

The script loads the `.env` file and exercises every read-only endpoint we can touch with your credentials (organization, pods, domains, lists, threads, inbox messages, etc.). If `SMOKE_TEST_SEND_EMAIL=true`, it also delivers a short email to the configured recipient so you can confirm outbound delivery end-to-end.

## License

MIT © [Toadstool Labs](http://toadstool.tech)
