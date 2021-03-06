require 'spec_helper'

describe Person do

  before :each do
    3.times do
      FactoryGirl.create :person
    end
  end

  describe "class methods" do

    context "search" do
      it "finds existing resources" do
        string = Person.first.first_name
        Person.text_rank_search(string).count('*').should >= 1
      end
      
      it "prevents sql injection" do
        string = "string ' with quotes"
        lambda {Person.text_search(string)}.should_not raise_error
      end
    end

  end
end
