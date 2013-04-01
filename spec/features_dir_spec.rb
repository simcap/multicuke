require 'spec_helper' 

module Multicuke
  
  describe FeaturesDir do
    it "return human readable directory name" do
      features = FeaturesDir.new("bye_bye_blackbird")
      features.human_name.should == "Bye bye blackbird"
      other_features = FeaturesDir.new("bye-bye-blackbird")
      other_features.human_name.should == "Bye bye blackbird"
    end

    it "return failed true when scenarios contain failures" do
      features = FeaturesDir.new("")
      features.scenarios_results = "1 passed, 1 failed"
      features.should be_failed
    end

    it "return failed true when steps contain failures" do
      features = FeaturesDir.new("")
      features.steps_results = "1 passed, 1 failed"
      features.should be_failed
    end
    
    it "return failed false when steps or scenarios do not contain failures" do
      features = FeaturesDir.new("")
      features.steps_results = "1 passed"
      features.scenarios_results = "1 passed"
      features.should_not be_failed
    end
  end
  
end
