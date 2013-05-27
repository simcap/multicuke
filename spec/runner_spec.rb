require 'spec_helper'

module Multicuke

  describe Runner do
      it "initializes with provided configuration" do
        runner = Multicuke::Runner.new("my_feature_path") do |r|
          r.output_dir_name = "my_reports"
          r.output_path = "my_output_path"
          r.dry_run = true
          r.require_features_root_option = false
          r.forks_pool_size = 10
          r.excluded_dirs = ["my_first_dir", "my_second_dir"]
          r.extra_options = ["-p", "profile"]
        end

        runner.features_root_path.should == "my_feature_path"
        runner.output_dir_name.should == "my_reports"
        runner.output_path.should == "my_output_path"
        runner.dry_run.should be_true
        runner.forks_pool_size.should == 10
        runner.require_features_root_option.should be_false
        runner.excluded_dirs.should include("my_first_dir", "my_second_dir")
        runner.extra_options.should include("-p", "profile")
      end

      it "initializes with default values" do
        runner = Multicuke::Runner.new(File.expand_path("../features", __FILE__))
        runner.output_dir_name.should == "cucumber_reports"
        runner.output_path.should match "multicuke/spec$"
        runner.dry_run.should be_false
        runner.forks_pool_size.should == 5
        runner.require_features_root_option.should be_true
        runner.excluded_dirs.should be_empty
        runner.extra_options.should be_empty
      end

      it "exits with 0 when all features succeed " do
        system_command_stub = double("SystemCommand")
        system_command_stub.stub(:run).and_return(true,true)
        system_command_stub.should_receive(:exit) {0}
        features_root = File.expand_path("../features", __FILE__)
        runner = Multicuke::Runner.new(features_root) do |r|
          r.included_only_dirs = ["addition","division"]
          r.dry_run = true
          r.output_path = RESULTS_DIR_PATH
          r.system_command = system_command_stub
        end 
        runner.start
      end
      it "exits with 1 when one feature fails " do
        system_command_stub = double("SystemCommand")
        system_command_stub.stub(:run).and_return(true,false)
        system_command_stub.should_receive(:exit) {1}
        features_root = File.expand_path("../features", __FILE__)
        runner = Multicuke::Runner.new(features_root) do |r|
          r.included_only_dirs = ["addition","division"]
          r.dry_run = true
          r.output_path = RESULTS_DIR_PATH
          r.system_command = system_command_stub
        end 
        runner.start
      end
       it "exits with 2 when two feature fail" do
        system_command_stub = double("SystemCommand")
        system_command_stub.stub(:run).and_return(true,false,false)
        system_command_stub.should_receive(:exit) {2}
        features_root = File.expand_path("../features", __FILE__)
        runner = Multicuke::Runner.new(features_root) do |r|
          r.included_only_dirs = ["addition","division","empty"]
          r.dry_run = true
          r.output_path = RESULTS_DIR_PATH
          r.system_command = system_command_stub
        end 
        runner.start
      end
    end

end