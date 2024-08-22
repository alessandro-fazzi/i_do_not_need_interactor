# frozen_string_literal: true

require "shy/interactor/version"
require "shy/interactor/context"

module Shy
  module Interactor # rubocop:disable Style/Documentation
    class Error < StandardError; end
    @config = {}

    class << self
      attr_reader :config

      def configure
        yield config
      end
    end

    def self.included(descendant)
      class << descendant
        def >>(other) = method(:call).public_send(:>>, other)

        def <<(other) = method(:call).public_send(:<<, other)

        def call(ctx = {}) = new.maybe_call(ctx)
      end
    end

    attr_accessor :failed

    def initialize
      @failed = false
    end

    def maybe_call(ctx = Context.new)
      ctx = Context.new(**ctx) unless ctx.is_a?(Context)

      return ctx if ctx.failure?

      run_validation(ctx)

      actually_call(ctx) if ctx.success?

      trigger_rollback(ctx) if ctx.failure?

      ctx
    end

    def rollback(ctx); end

    private

    def run_validation(ctx)
      return ctx unless respond_to?(:validate)

      validate(ctx)
      self.failed = ctx.failure?

      ctx
    end

    def actually_call(ctx)
      ctx.register(self)
      send(callable_method, ctx)
      self.failed = ctx.failure?

      ctx
    end

    def callable_method = :call

    def trigger_rollback(ctx) = ctx._executed.reverse_each { _1.rollback(ctx) }
  end
end
