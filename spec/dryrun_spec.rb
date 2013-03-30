require 'spec_helper' 

module Multicuke
  
  describe "Reporting" do

    after(:each) do
      FileUtils.rm_r(Dir.glob("#{RESULTS_DIR_PATH}/*"), :force => true)
    end
    
    it "generates index file in output folder" do
      runner = Multicuke::Runner.new do |r|
        r.features_dir_path = File.expand_path("../features", __FILE__)
        r.output_dir_name = "cuke_reports"
        r.dry_run = true
        r.output_path = RESULTS_DIR_PATH
      end 

      File.should_not exist("#{RESULTS_DIR_PATH}/cuke_reports")

      runner.start
      
      File.should exist("#{RESULTS_DIR_PATH}/cuke_reports/index.html")
    end

    it "write link to each features on index file" do
      runner = Multicuke::Runner.new do |r|
        r.features_dir_path = File.expand_path("../features", __FILE__)
        r.excluded_dirs = ["steps_definition"]
        r.dry_run = true
        r.output_path = RESULTS_DIR_PATH
      end 

      runner.start
      
      File.open("#{RESULTS_DIR_PATH}/cucumber_reports/index.html") { |file|
        content = file.read
        content.should match /.*Cucumber reports.*/
        content.should match /.*<a href="addition.html">addition<\/a>.*/
        content.should match /.*<a href="substraction.html">substraction<\/a>.*/
        content.should match /.*<a href="division.html">division<\/a>.*/
        content.should match /.*<a href="multiplication.html">multiplication<\/a>.*/
        content.should_not match /.*steps_definition.*/
      }
    end

  end

end