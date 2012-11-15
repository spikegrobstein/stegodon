require File.dirname(__FILE__) + '/spec_helper'

describe Stegodon::Configuration do

  before do
    Stegodon::Configuration.destroy_all
  end

  context "when creating configurations" do

    it "should create a new configuration in the collection" do
      c = Stegodon::Configuration.new(:default) do
        host "default-host"
        username "default-user"
      end

      Stegodon::Configuration.get(:default).should == c
    end

    it "should overwrite configurations in the collection" do
      d = Stegodon::Configuration.new(:default) do
        host "default-host"
        username "default-user"
      end

      Stegodon::Configuration.new(:default) do
        host "new-defaults"
        username "new-default-user"
      end

      c = Stegodon::Configuration.get(:default)

      c.host.should == 'new-defaults'
      Stegodon::Configuration.configurations.count.should == 1
    end

  end

  context ".destroy_all" do

    it "should destroy all configurations" do

      Stegodon::Configuration.new(:a)
      Stegodon::Configuration.new(:b)

      Stegodon::Configuration.destroy_all
      Stegodon::Configuration.configurations.count.should == 0

    end

  end

  context ".configurations" do

    it "should return all configurations" do

      Stegodon::Configuration.new(:a)
      Stegodon::Configuration.new(:b)

      Stegodon::Configuration.configurations.count.should == 2

    end

  end

  context ".get" do

    it "should return a configuration if it exists" do
      c = Stegodon::Configuration.new(:a)

      Stegodon::Configuration.get(:a).should == c
    end

    it "should raise an error if the configuration does not exist" do
      Stegodon::Configuration.new(:a)

      lambda { Stegodon::Configuration.get(:b) }.should raise_error(Stegodon::Configuration::UnknownConfiguration)
    end

  end

end

