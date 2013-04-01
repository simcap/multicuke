require 'spec_helper' 

module Multicuke
  
  describe "Forking" do

    before(:each) do
      FileUtils.rm_r(Dir.glob("#{RESULTS_DIR_PATH}/*"), :force => true)
    end

    it "generates test results files" do
      runner = Multicuke::Runner.new do |r|
        r.features_root_path = File.expand_path("../features", __FILE__)
        r.excluded_dirs = ["steps_definition"]
        r.output_path = RESULTS_DIR_PATH
      end

      runner.start
      
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/addition.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/division.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/multiplication.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/substraction.html")
    
      File.open("#{RESULTS_DIR_PATH}/cucumber_reports/index.html") { |file|
        content = file.read
        content.should match /.*Scenarios: 1 failed, Steps: 1 failed, 3 passed.*/i
      }
    end

  end
end