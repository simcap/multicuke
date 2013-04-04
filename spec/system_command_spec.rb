require 'spec_helper'

describe "System command" do

  it "runs 'bundle exec cucumber ...' command" do
    runner = Multicuke::Runner.new do |r|
      r.features_root_path = File.expand_path("../features", __FILE__)
      r.included_only_dirs = ["addition"]
      r.output_path = RESULTS_DIR_PATH
      r.system_command = mock('SystemCommand mock')
    end

    runner.should_receive(:fork)
    runner.start

  end

end