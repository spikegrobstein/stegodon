require File.dirname(__FILE__) + '/spec_helper'

describe Stegodon::DSL do

  class TestDSL < Stegodon::Base

    dsl_accessor :name, :size

    attr_accessor :is_large

    def size=(new_size)
      self.is_large = ( new_size > 10 )
      @size = new_size
    end

  end

  context "when running the DSL" do

    it "should error out when an unknown function is called" do
      lambda { TestDSL.new { relative "bob" } }.should raise_error
    end

    it "should set the appropriate attribute on the parent" do
      t = TestDSL.new do
        name 'spike'
      end

      t.name.should == 'spike'
    end

    it "should allow overrides on the setters for the variables" do
      t = TestDSL.new do
        size 5
      end

      t.is_large.should be_false

      u = TestDSL.new do
        size 50
      end

      u.is_large.should be_true
    end

  end

end
