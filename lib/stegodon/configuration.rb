module Stegadon
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

    def get(name)
      @@configurations[name]
    end

  end
end
