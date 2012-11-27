require File.dirname(__FILE__) + '/spec_helper'

describe Stegodon::Loader do

  context "#verbose" do
    before do
      Stegodon::Loader.any_instance.stub(:load! => false)
    end

    it "should default to true if verbose is called in DSL" do
      l = Stegodon::Loader.new do
        verbose
      end

      l.verbose.should be_true
    end

    it "should set verbose to false if false is called in DSL" do
      l = Stegodon::Loader.new do
        verbose false
      end

      l.verbose.should be_false
    end

    it "should set verbose to true if true is called in DSL" do
      l = Stegodon::Loader.new do
        verbose true
      end

      l.verbose.should be_true
    end

  end

end
