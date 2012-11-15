module Stegodon
  class Configuration < Base

    @@configurations = {}

    dsl_accessor :host,
      :username,
      :password,
      :port

    def initialize(name, &block)
      @@configurations[name] = self
      run_dsl &block
    end

    def self.get(name)
      @@configurations[name]
    end

  end
end
