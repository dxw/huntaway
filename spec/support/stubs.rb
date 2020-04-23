module Stubs
  def stub_list_group_memberships
    stub_request(:get, "#{ENV["ZENDESK_API_URL"]}/group_memberships")
      .to_return(stubbed_json_body("group_memberships.json"))
  end

  def stub_delete_group_membership(membership_id)
    stub_request(:delete, "#{ENV["ZENDESK_API_URL"]}/group_memberships/#{membership_id}.json")
      .to_return(status: 200, body: "", headers: {})
  end

  def stub_opsgenie_schedule
    stub_request(:get, "https://api.opsgenie.com/v2/schedules/e71d500f-896a-4b28-8b08-3bfe56e1ed76?identifierType=id")
      .to_return(stubbed_json_body("opsgenie_schedule.json"))
  end

  def stub_opsgenie_oncalls
    stub_request(:get, "https://api.opsgenie.com/v2/schedules/e71d500f-896a-4b28-8b08-3bfe56e1ed76/on-calls?date=2020-04-23T12:00:00%2B00:00")
      .to_return(stubbed_json_body("opsgenie_oncalls.json"))
  end

  def stub_opsgenie_users
    stub_request(:get, "https://api.opsgenie.com/v2/users?limit=500")
      .to_return(stubbed_json_body("opsgenie_users.json"))
  end

  def stub_zendesk_user_search(query)
    stub_request(:get, "#{ENV["ZENDESK_API_URL"]}/users/search?query=#{query}")
      .to_return(stubbed_json_body("zendesk_user_search.json"))
  end

  def stub_group_membership_creation(user_id:, group_id:)
    stub_request(:post, "#{ENV["ZENDESK_API_URL"]}/group_memberships")
      .with(
        body: {
          "group_membership": {
            "user_id": user_id,
            "group_id": group_id
          }
        }.to_json
      ).to_return(status: 201, body: "", headers: {})
  end

  def stubbed_json_body(filename)
    {
      status: 200,
      body: get_fixture_file(filename),
      headers: {
        "Content-Type": "application/json"
      }
    }
  end

  def get_fixture_file(filename)
    File.open(File.join(__dir__, "..", "fixtures", filename)).read
  end
end

RSpec.configure do |config|
  config.include Stubs
end
