# frozen_string_literal: true

require_relative "lib/agentmail/version"

Gem::Specification.new do |spec|
  spec.name = "agentmail"
  spec.version = Agentmail::VERSION
  spec.authors = ["Toadstool Labs"]
  spec.email = ["hello@toadstool.tech"]

  spec.summary = "Lightweight Ruby client for the AgentMail API."
  spec.description = "A small, well-tested HTTP wrapper around the AgentMail API inspired by the official Python SDK."
  spec.homepage = "https://github.com/agentmail-to/agentmail-ruby"
  spec.required_ruby_version = ">= 3.2.0"

  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore spec/ test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.0"
  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "webmock", "~> 3.23"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
