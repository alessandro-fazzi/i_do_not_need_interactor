# frozen_string_literal: true

require_relative "i_do_not_need_interactor/version"

module IDoNotNeedInteractor
  class Error < StandardError; end

  def self.included(descendant)
    class << descendant
      def pipe
        new.method(:maybe_call)
      end

      def call(ctx = Context.new)
        new.maybe_call(ctx)
        ctx
      end
    end
  end

  def maybe_call(ctx = Context.new)
    return ctx if ctx.failure?

    call(ctx)
    ctx.register(self)

    ctx._executed.reverse_each { _1.rollback(ctx) } if ctx.failure?

    ctx
  end

  def rollback(ctx); end

  class Context < Hash
    attr_reader :errors, :_executed

    def initialize(**initial_values)
      super()
      @errors = []
      @_executed = []
      initial_values.to_hash.each { |key, value| self[key] = value }
    end

    def register(object)
      @_executed << object
    end

    def success? = errors.empty?

    def failure? = !success?
  end
end

Interactor = IDoNotNeedInteractor unless Module.const_defined?("Interactor")
