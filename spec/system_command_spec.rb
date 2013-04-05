require 'spec_helper'

describe "System command" do

  it "runs 'bundle exec cucumber ...' command" do
    features_root = File.expand_path("../features", __FILE__)
    runner = Multicuke::Runner.new(features_root) do |r|
      r.included_only_dirs = ["addition"]
      r.output_path = RESULTS_DIR_PATH
      r.system_command = mock('SystemCommand mock')
    end

    runner.should_receive(:fork)
    runner.start

  end

end