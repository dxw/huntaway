ENV["FIRST_LINE_DEV_SUPPORT_GROUP_ID"] = "444111"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "huntaway"
require "timecop"
require "webmock/rspec"
require "support/stubs"

ENV["ZENDESK_API_URL"] = "https://example.zendesk.com/api/v2"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
