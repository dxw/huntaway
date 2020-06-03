require "zendesk_api"
require "dotenv"
require "opsgenie"

Dotenv.load
Opsgenie.configure(api_key: ENV.fetch("OPSGENIE_API_KEY"))

class Huntaway
  FIRST_LINE_DEV_SUPPORT_GROUP_ID = ENV.fetch("FIRST_LINE_DEV_SUPPORT_GROUP_ID").to_i
  OPSGENIE_SCHEDULE_ID = ENV.fetch("OPSGENIE_SCHEDULE_ID")

  def run!
    @existing_group_memberships = []
    @current_support_user_ids = current_support_user_ids.freeze

    unassign_extra_users_from_group
    assign_missing_support_users_to_group
  end

  private

  def assign_missing_support_users_to_group
    @current_support_user_ids.each do |id|
      unless @existing_group_memberships.include?(id)
        client.group_memberships.create!(user_id: id, group_id: FIRST_LINE_DEV_SUPPORT_GROUP_ID)
      end
    end
  end

  def unassign_extra_users_from_group
    client.group_memberships.all! do |group_membership|
      if group_membership["group_id"] == FIRST_LINE_DEV_SUPPORT_GROUP_ID
        @existing_group_memberships << group_membership["user_id"]
        unless @current_support_user_ids.include?(group_membership["user_id"])
          group_membership.destroy!
        end
      end
    end
  end

  def client
    @client ||= begin
      ZendeskAPI::Client.new do |config|
        config.url = ENV.fetch("ZENDESK_API_URL")
        config.username = ENV.fetch("ZENDESK_USERNAME")
        config.token = ENV.fetch("ZENDESK_API_KEY")
      end
    end
  end

  def opsgenie_schedule
    @opsgenie_schedule ||= Opsgenie::Schedule.find_by_id(OPSGENIE_SCHEDULE_ID)
  end

  def current_support_user_ids
    current_support_users.map { |u|
      user = client.users.search(query: u.username).first
      user.fetch(:id, nil)
    }.compact.uniq
  end

  def current_support_users
    today = DateTime.now
    date = DateTime.new(today.year, today.month, today.day, 12, 0o0)
    opsgenie_schedule.on_calls(date)
  end
end
