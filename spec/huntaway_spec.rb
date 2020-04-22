require "spec_helper"

RSpec.describe Huntaway do
  let!(:list_group_memberships) do
    stub_request(:get, "https://dxw.zendesk.com/api/v2/group_memberships")
      .to_return(status: 200, body: {
        "group_memberships": [
          {
            "url": "https://dxw.zendesk.com/api/v2/group_memberships/126699.json",
            "id": 126699,
            "user_id": 10793415,
            "group_id": 72939,
            "default": true,
            "created_at": nil,
            "updated_at": "2013-04-01T14:47:53Z"
          },
          {
            "url": "https://dxw.zendesk.com/api/v2/group_memberships/144996.json",
            "id": 144996,
            "user_id": 13062170,
            "group_id": Huntaway::GROUP_ID,
            "default": true,
            "created_at": nil,
            "updated_at": "2013-04-01T14:48:21Z"
          }
        ]
      }.to_json,
                 headers: {
                   "Content-Type": "application/json"
                 })
  end

  let!(:delete_group) do
    stub_request(:delete, "https://dxw.zendesk.com/api/v2/group_memberships/144996.json")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "ZendeskAPI Ruby 1.25.0"
        }
      )
      .to_return(status: 200, body: "", headers: {})
  end

  let!(:opsgenie_schedule) do
    stub_request(:get, "https://api.opsgenie.com/v2/schedules/e71d500f-896a-4b28-8b08-3bfe56e1ed76?identifierType=id")
      .to_return(status: 200, body: {
        "data": {
          "id": "e71d500f-896a-4b28-8b08-3bfe56e1ed76",
          "name": "first_line",
          "description": "",
          "timezone": "Europe/London",
          "enabled": true,
          "ownerTeam": {
            "id": "72c99d92-c7c8-4fd9-b8db-9cc293cd19e7",
            "name": "support_team"
          },
          "rotations": []
        }
      }.to_json,
                 headers: {
                   "Content-Type": "application/json"
                 })
  end

  let!(:opsgenie_oncalls) do
    stub_request(:get, "https://api.opsgenie.com/v2/schedules/e71d500f-896a-4b28-8b08-3bfe56e1ed76/on-calls")
      .to_return(status: 200, body: {
        "data": {
          "_parent": {
            "id": "e71d500f-896a-4b28-8b08-3bfe56e1ed76",
            "name": "first_line",
            "enabled": true
          },
          "onCallParticipants": [
            {
              "id": "19e39115-07d5-4924-8295-332a66dd1569",
              "name": "example@dxw.com",
              "type": "user"
            }
          ]
        },
        "took": 0.011,
        "requestId": "bf43f7e7-ce2b-4142-ba26-d5c90d7a5547"
      }.to_json,
                 headers: {
                   "Content-Type": "application/json"
                 })
  end

  let!(:opsgenie_user) do
    stub_request(:get, "https://api.opsgenie.com/v2/users?limit=500")
      .to_return(status: 200, body: {
        "data": [
          {
            "blocked": false,
            "verified": true,
            "id": "8be02293-95fb-43d1-91cf-703ba8c74934",
            "username": "example@dxw.com",
            "fullName": "example example",
            "role": {
              "id": "Owner",
              "name": "Owner"
            },
            "timeZone": "Europe/London",
            "locale": "en_GB",
            "userAddress": {
              "country": "",
              "state": "",
              "city": "",
              "line": "",
              "zipCode": ""
            },
            "createdAt": "2018-03-01T14:49:54.678Z"
          }
        ]
      }.to_json, headers: {
        "Content-Type": "application/json"
      })
  end

  let!(:user_search_stub) do
    stub_request(:get, "https://dxw.zendesk.com/api/v2/users/search?query=example@dxw.com")
      .to_return(status: 200, body: {
        "users": [
          {
            "id": 375550676351
          }
        ],
        "next_page": nil,
        "previous_page": nil,
        "count": 1
      }.to_json, headers: {
        "Content-Type": "application/json"
      })
  end

  let!(:group_membership_creation) do
    stub_request(:post, "https://dxw.zendesk.com/api/v2/group_memberships")
      .with(
        body: {
          "group_membership": {
            "user_id": 375550676351,
            "group_id": 360008997631
          }
        }.to_json
      ).to_return(status: 201, body: "", headers: {})
  end

  it "deletes all group memberships" do
    described_class.new.run!
    expect(delete_group).to have_been_made.once
  end

  it "creates group memberships for the oncall user" do
    described_class.new.run!
    expect(group_membership_creation).to have_been_made.once
  end
end
