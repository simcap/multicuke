require 'spec_helper'  

module Multicuke

  describe Runner do
      it "initializes with provided configuration" do
        runner = Multicuke::Runner.new do |r|
          r.features_root_path = "my_feature_path"
          r.output_dir_name = "my_reports"
          r.output_path = "my_output_path"
          r.dry_run = true
          r.excluded_dirs = ["my_first_dir", "my_second_dir"]
        end

        runner.features_root_path.should == "my_feature_path"
        runner.output_dir_name.should == "my_reports"
        runner.output_path.should == "my_output_path"
        runner.dry_run.should be_true
        runner.excluded_dirs.should include("my_first_dir", "my_second_dir")
      end

      it "initializes with default values" do
        runner = Multicuke::Runner.new

        runner.output_dir_name.should == "cucumber_reports"
        runner.output_path.should == ""
        runner.dry_run.should be_false
        runner.excluded_dirs.should be_empty
      end
    end  

end