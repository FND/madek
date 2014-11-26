require 'spec_helper'
require Rails.root.join "spec", "models", "shared", "favoritable_spec.rb"

describe Collection do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :collection}.not_to raise_error
    end

  end

  context "an existing Collection" do

    it_behaves_like "a favoritable" do

      let(:resource) { FactoryGirl.create :collection }

    end

  end
end
