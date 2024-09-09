# frozen_string_literal: true

require "dry-validation"

module Shy
  module Interactor
    module Contract
      module DryValidation # rubocop:disable Style/Documentation
        def self.included(descendant)
          class << descendant
            def contract(&)
              @contract = Class.new(::Dry::Validation::Contract)
              @contract.class_exec(&)
            end

            def validate(proc)
              @type_validation_proc = proc
            end
          end
        end

        module Types # rubocop:disable Style/Documentation
          include Dry.Types()
        end

        def validate(ctx)
          if is_a?(Shy::Interactor)
            validate_interactor(ctx)
          elsif is_a?(Shy::Interactor::Railway)
            result = ctx
            validate_railway_interactor(result)
          end
        end

        private

        def validate_interactor(ctx)
          validation_result = self.class.instance_variable_get(:@contract).new.call(ctx)
          ctx.errors << validation_result.errors.to_h if validation_result.errors.any?
        end

        def validate_railway_interactor(result)
          if result.respond_to?(:to_h) && self.class.instance_variable_defined?(:@contract)
            validate_railway_interactor_with_contract(result.to_h)
          elsif self.class.instance_variable_defined?(:@type_validation_proc)
            validate_railway_interactor_with_type(result)
          else
            raise Error, <<~ERROR
              Interactor #{self.class} requires validation, but you have not
              defined neither `contract` or `validate` methods on the class.
            ERROR
          end
        end

        def validate_railway_interactor_with_contract(result)
          validation_result = self.class.instance_variable_get(:@contract).new.call(result)
          Failure(validation_result.errors.to_h) if validation_result.errors.any?
        end

        def validate_railway_interactor_with_type(result)
          self.class.instance_variable_get(:@type_validation_proc).call(result)
        rescue Dry::Types::ConstraintError => e
          Failure(e.message)
        end
      end
    end
  end
end
