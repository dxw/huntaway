require "spec_helper"

RSpec.describe Huntaway do
  before do
    Timecop.freeze("2020-04-23")
    stub_list_group_memberships
    stub_opsgenie_schedule
    stub_opsgenie_oncalls
    stub_opsgenie_users
    stub_zendesk_user_search("example@dxw.com")
  end

  after do
    Timecop.return
  end

  let!(:delete_group) { stub_delete_group_membership(144996) }
  let!(:group_membership_creation) { stub_group_membership_creation(user_id: 375550676351, group_id: 360008997631) }

  it "deletes all group memberships" do
    described_class.new.run!
    expect(delete_group).to have_been_made.once
  end

  it "creates group memberships for the oncall user" do
    described_class.new.run!
    expect(group_membership_creation).to have_been_made.once
  end
end
