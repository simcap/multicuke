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
    end

end