require 'spec_helper' 

module Multicuke
  
  describe "Forking" do

    it "generates test results files" do
      runner = Multicuke::Runner.new do |r|
        r.features_dir_path = File.expand_path("../features", __FILE__)
        r.excluded_dirs = ["steps_definition"]
        r.output_path = RESULTS_DIR_PATH
      end

      runner.start
      
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/addition.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/division.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/multiplication.html")
      File.should exist("#{RESULTS_DIR_PATH}/cucumber_reports/substraction.html")
    end

  end
end