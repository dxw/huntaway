$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require "huntaway"

require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec)

task default: %i[standard spec]

namespace :huntaway do
  task :assign_incoming_support_user do
    Huntaway.new.assign_incoming_support_user!
  end

  task :unassign_extra_users_from_group do
    Huntaway.new.unassign_extra_users_from_group!
  end
end
