require 'spec_helper' 

module Multicuke
  
  describe "Forking" do

    before(:each) do
      FileUtils.rm_r(Dir.glob("#{RESULTS_DIR_PATH}/*"), :force => true)
    end

    it "generates test results files" do
      features_root = File.expand_path("../features", __FILE__)
      runner = Multicuke::Runner.new(features_root) do |r|
        r.excluded_dirs = ["steps_definition"]
        r.extra_options = ["-t", "~@non_existing_tag"]
        r.output_path = RESULTS_DIR_PATH
      end

      expect{runner.start}.to raise_error SystemExit
      
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/addition.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/division.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/multiplication.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/substraction.html")
    
      File.open("#{RESULTS_DIR_PATH}/cucumber_reports/index.html") { |file|
        content = file.read
        content.should match /.*<a href="addition.html">Addition<\/a>.*/
        content.should match /.*<a href="substraction.html">Substraction<\/a>.*/
        content.should match /.*<a href="division.html">Division<\/a>.*/
        content.should match /.*<a href="bad_addition.html">Bad addition<\/a>.*/
        content.should match /.*<a href="multiplication.html">Multiplication<\/a>.*/

        division_sections = content.scan(/(<a href="division.html">Division<\/a>)/)
        division_sections.should have(1).items

        content.should match /.*Scenarios: 1 failed, Steps: 1 failed, 3 passed.*/i
      }
    end

  end
end