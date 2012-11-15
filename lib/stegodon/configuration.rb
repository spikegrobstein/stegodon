module Stegodon
  class Configuration < Base

    class UnknownConfiguration < StandardError; end

    @@configurations = {}

    dsl_accessor :host,
      :username,
      :password,
      :port

    def initialize(name, &block)
      @@configurations[name] = self
      super
    end

    def self.get(name)
      @@configurations[name] || raise(UnknownConfiguration.new "Unknown configuration: #{ name }")
    end

    def self.configurations
      @@configurations
    end

    def self.destroy_all
      @@configurations = {}
    end

  end
end
