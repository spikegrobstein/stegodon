module Stogodon
  class DSL
    attr_accessor :parent

    def initialize(p)
      @parent = p
    end

    def method_missing(method, *args, &block)
      if @parent.class.dsl_attributes.include?(method)
        @parent.send("#{ method }=", *args)
      else
        super
      end
    end
  end
end
