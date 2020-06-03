require "spec_helper"

RSpec.describe Huntaway do
  before do
    Timecop.freeze("2020-04-23")
    stub_list_group_memberships
    stub_opsgenie_schedule
    stub_opsgenie_oncalls
    stub_opsgenie_users
    stub_zendesk_user_search("in_group_on_support@example.com", "in_on")
    stub_zendesk_user_search("out_group_on_support@example.com", "out_on")
  end

  after do
    Timecop.return
  end

  let!(:wanted_membership_deletion) { stub_delete_group_membership(888100) }
  let!(:unwanted_membership_deletion) { stub_delete_group_membership(888101) }
  let!(:other_group_membership_deletion) { stub_delete_group_membership(555000) }
  let!(:wanted_membership_creation) { stub_group_membership_creation(user_id: 999001, group_id: ENV["FIRST_LINE_DEV_SUPPORT_GROUP_ID"].to_i) }
  let!(:unwanted_membership_creation) { stub_group_membership_creation(user_id: 999101, group_id: ENV["FIRST_LINE_DEV_SUPPORT_GROUP_ID"].to_i) }

  it "deletes group memberships for users in group but not on support" do
    described_class.new.run!
    expect(wanted_membership_deletion).to have_been_made.once
  end

  it "does not delete group memberships for users in group and on support" do
    described_class.new.run!
    expect(unwanted_membership_deletion).to_not have_been_made
  end

  it "does not delete memberships of other groups" do
    described_class.new.run!
    expect(other_group_membership_deletion).to_not have_been_made
  end

  it "creates group memberships for users on support and not in group" do
    described_class.new.run!
    expect(wanted_membership_creation).to have_been_made.once
  end

  it "does not create group memberships for users on support and already in group" do
    described_class.new.run!
    expect(unwanted_membership_creation).to_not have_been_made
  end
end
