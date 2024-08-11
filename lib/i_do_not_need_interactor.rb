# frozen_string_literal: true

require_relative "i_do_not_need_interactor/version"

module IDoNotNeedInteractor # rubocop:disable Style/Documentation
  class Error < StandardError; end

  def self.included(descendant)
    class << descendant
      def pipe
        new.method(:maybe_call)
      end

      def call(ctx = Context.new)
        ctx = Context.new(**ctx) unless ctx.is_a?(Context)
        new.maybe_call(ctx)
        ctx
      end
    end
  end

  def maybe_call(ctx = Context.new)
    return ctx if ctx.failure?

    if respond_to?(:validate)
      validate(ctx)
      return ctx if ctx.failure?
    end

    call(ctx)
    ctx.register(self)

    ctx._executed.reverse_each { _1.rollback(ctx) } if ctx.failure?

    ctx
  end

  def rollback(ctx); end

  class Context < Hash # rubocop:disable Style/Documentation
    attr_reader :errors, :_executed

    def initialize(**initial_values)
      super()
      @errors = []
      @_executed = []
      merge! initial_values
    end

    def register(object)
      @_executed << object
    end

    def success? = errors.empty?

    def failure? = !success?
  end

  module Contract
    module ActiveModel # rubocop:disable Style/Documentation
      def self.included(descendant) # rubocop:disable Metrics/MethodLength
        class << descendant
          def contract(&block)
            @contract = Class.new do
              include ::ActiveModel::API
              include ::ActiveModel::Attributes
              include ::ActiveModel::Validations

              def self.model_name
                ::ActiveModel::Name.new(self, nil, "temp")
              end
            end
            @contract.class_exec(&block)
          end
        end
      end

      def validate(ctx)
        self.class.instance_variable_get(:@contract).new(**ctx).validate!
      rescue ::ActiveModel::ValidationError => e
        ctx.errors << e.message
      end
    end

    module DryValidation # rubocop:disable Style/Documentation
      def self.included(descendant)
        class << descendant
          def contract(&block)
            @contract = Class.new(::Dry::Validation::Contract)
            @contract.class_exec(&block)
          end
        end
      end

      def validate(ctx)
        validation_result = self.class.instance_variable_get(:@contract).new.call(ctx)
        ctx.errors << validation_result.errors.to_h if validation_result.errors.any?
      end
    end
  end
end

Interactor = IDoNotNeedInteractor unless Module.const_defined?("Interactor")
