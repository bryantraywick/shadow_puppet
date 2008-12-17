require 'puppet'
require 'puppet/dsl'

module Moonshine
  class Manifest
    include Puppet::DSL

    attr_reader :application

    def initialize(application)
      init
      @application = application
    end

    def manifest
      self
    end

    def run
    end

    def define(&block)
      @block = block
      instance_eval(&@block)
    end

    def role(name, options = {}, &block)
      Puppet::DSL::Aspect.new(name, options, &block)
    end

    def roles(*names)
      acquire(*names)
      apply
    end

  end
end

Dir.glob(File.join(File.dirname(__FILE__), '..', 'facts', '*.rb')).each do |fact|
  require fact
end
Dir.glob(File.join(File.dirname(__FILE__), 'manifest', '*.rb')).each do |manifest|
  require manifest
end