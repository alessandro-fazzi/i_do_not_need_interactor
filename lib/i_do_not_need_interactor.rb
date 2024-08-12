# frozen_string_literal: true

require "i_do_not_need_interactor/version"
require "i_do_not_need_interactor/context"

module IDoNotNeedInteractor # rubocop:disable Style/Documentation
  class Error < StandardError; end

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
    return ctx if run_validation(ctx).failure?

    actually_call(ctx)

    trigger_callback(ctx) if ctx.failure?

    ctx
  end

  def rollback(ctx); end

  private

  def run_validation(ctx)
    return ctx unless respond_to?(:validate)

    validate(ctx)

    ctx
  end

  def actually_call(ctx)
    call(ctx)
    ctx.register(self)
    self.failed = ctx.failure?

    ctx
  end

  def trigger_callback(ctx)
    ctx._executed.reverse_each { _1.rollback(ctx) }
  end
end

Interactor = IDoNotNeedInteractor unless Module.const_defined?("Interactor")
