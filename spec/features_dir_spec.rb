require 'spec_helper' 

module Multicuke
  
  describe FeaturesDir do
    it "return human readable directory name" do
      features = FeaturesDir.new("bye_bye_blackbird")
      features.human_name.should == "Bye bye blackbird"
      other_features = FeaturesDir.new("bye-bye-blackbird")
      other_features.human_name.should == "Bye bye blackbird"
    end
  end
  
end
