module Stegodon
  class Base

    def self.dsl_accessor(*vars)
      @dsl_attributes ||= []
      @dsl_attributes.concat vars

      attr_accessor *vars
    end

    def self.dsl_attributes
      @dsl_attributes
    end

    def run_dsl(file=nil, &block)
      dsl = DSL.new(self)
      dsl.instance_eval(&block)
    end

  end
end
