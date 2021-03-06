require 'spec_helper' 

module Multicuke
  
  describe "Reporting" do

    let(:system_command_stub) { stub('SystemCommand stub').as_null_object }

    after(:each) do
      FileUtils.rm_r(Dir.glob("#{RESULTS_DIR_PATH}/*"), :force => true)
    end
    
    it "generates index file with hyperlinks to each feature" do
      features_root = File.expand_path("../features", __FILE__)
      runner = Multicuke::Runner.new(features_root) do |r|
        r.output_dir_name = "cuke_reports"
        r.dry_run = true
        r.output_path = RESULTS_DIR_PATH
        r.system_command = system_command_stub
      end 

      File.should_not exist("#{RESULTS_DIR_PATH}/cuke_reports")

      runner.start
      
      File.open("#{RESULTS_DIR_PATH}/cuke_reports/index.html") { |file|
        content = file.read
        content.should match /.*Cucumber reports.*/
        content.should match /.*<a href="addition.html">Addition<\/a>.*/
        content.should match /.*<a href="substraction.html">Substraction<\/a>.*/
        content.should match /.*<a href="division.html">Division<\/a>.*/
        content.should match /.*<a href="bad_addition.html">Bad addition<\/a>.*/
        content.should match /.*<a href="multiplication.html">Multiplication<\/a>.*/
        content.should_not match /.*steps_definition.*/
      }
    end

    it "do not run on excluded directories and those that do not contains features" do
      features_root = File.expand_path("../features", __FILE__)
      runner = Multicuke::Runner.new(features_root) do |r|
        r.features_root_path = 
        r.excluded_dirs = ["exclude_me_features"]
        r.dry_run = true
        r.output_path = RESULTS_DIR_PATH
        r.system_command = system_command_stub
      end 

      runner.start
      
      File.open("#{RESULTS_DIR_PATH}/cucumber_reports/index.html") { |file|
        content = file.read
        content.should_not match /.*steps_definition.*/
        content.should_not match /.*excluded_features.*/
      }
    end

    it "run on included dirs only" do
      features_root = File.expand_path("../features", __FILE__)
      runner = Multicuke::Runner.new(features_root) do |r|
        r.included_only_dirs = ["addition"]
        r.dry_run = true
        r.output_path = RESULTS_DIR_PATH
        r.system_command = system_command_stub
      end 

      File.should_not exist("#{RESULTS_DIR_PATH}/cucumber_reports")

      runner.start
      
      File.open("#{RESULTS_DIR_PATH}/cucumber_reports/index.html") { |file|
        content = file.read

        content.should match /.*<a href="addition.html">Addition<\/a>.*/

        content.should_not match /.*bad_addition.*/i
        content.should_not match /.*division.*/i
        content.should_not match /.*substraction.*/i
        content.should_not match /.*multiplication.*/i
        content.should_not match /.*steps_definition.*/
        content.should_not match /.*excluded_features.*/
      }
    end

  end

end