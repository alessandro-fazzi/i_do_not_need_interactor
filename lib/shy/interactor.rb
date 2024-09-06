# frozen_string_literal: true

require "shy/interactor/version"
require "shy/interactor/hash_refinements"
require "shy/interactor/context"
require "shy/interactor/logger"
require "shy/interactor/config"
require "shy/interactor/composable"
require "shy/interactor/railway"
require "shy/interactor/result"

module Shy
  module Interactor # rubocop:disable Style/Documentation
    class Error < StandardError; end

    extend Composable

    class << self
      attr_accessor :config

      def configure(...) = config.configure(...)
    end

    @config = Config.build_with_defaults

    attr_accessor :failed

    def initialize
      @failed = false
    end

    def maybe_call(ctx = Context.Hash)
      ctx = Context.Hash(**ctx) unless ctx.is_a?(ActsAsContext)

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
      logger.debug [ctx, "Executed #{self.class}"]

      ctx.register(self)
      send(callable_method, ctx)
      self.failed = ctx.failure?

      ctx
    end

    def callable_method = :call

    def trigger_rollback(ctx) = ctx._executed.reverse_each { _1.rollback(ctx) }

    def logger
      Shy::Interactor.config.logger
    end
  end
end
