# frozen_string_literal: true

require "dry-validation"

module IDoNotNeedInteractor
  module Contract
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
