require "zendesk_api"
require "dotenv"
require "opsgenie"

Dotenv.load
Opsgenie.configure(api_key: ENV["OPSGENIE_API_KEY"])

class Huntaway
  GROUP_ID = 360008997631
  OPSGENIE_SCHEDULE_ID = "e71d500f-896a-4b28-8b08-3bfe56e1ed76"

  def run!
    unassign_users_from_group
    assign_current_support_users_to_group
  end

  private

  def assign_current_support_users_to_group
    current_support_users.each do |user|
      user = client.users.search(query: user.username).first
      client.group_memberships.create!(user_id: user.id, group_id: GROUP_ID)
    end
  end

  def unassign_users_from_group
    client.group_memberships.all! do |group_membership|
      group_membership.destroy! if group_membership["group_id"] == GROUP_ID
    end
  end

  def client
    @client ||= begin
      ZendeskAPI::Client.new do |config|
        config.url = ENV["ZENDESK_API_URL"]
        config.username = ENV["ZENDESK_USERNAME"]
        config.token = ENV["ZENDESK_API_KEY"]
      end
    end
  end

  def opsgenie_schedule
    @opsgenie_schedule ||= Opsgenie::Schedule.find_by_id(OPSGENIE_SCHEDULE_ID)
  end

  def current_support_users
    today = DateTime.now
    date = DateTime.new(today.year, today.month, today.day, 12, 0o0)
    opsgenie_schedule.on_calls(date)
  end
end
