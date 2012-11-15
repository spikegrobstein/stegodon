require File.dirname(__FILE__) + '/spec_helper'

describe Stegodon::Base do

  class TestBase < Stegodon::Base
    dsl_accessor :test_attribute

  end

  context "dsl_accessor" do
    let(:test_base) { TestBase.new }

    it "should define a new attribute accessor" do
      test_base.respond_to?(:test_attribute).should be_true
      test_base.respond_to?(:test_attribute=).should be_true
    end

    it "should define a new dsl_attribute" do
      TestBase.dsl_attributes.should == [ :test_attribute ]
    end

  end

  context "dsl_attributes" do

    it "should return the dsl attributes defined on the class" do
      TestBase.dsl_attributes.should == [ :test_attribute ]
    end

  end

end
