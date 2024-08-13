# frozen_string_literal: true

require "active_model"

module IDoNotNeedInteractor
  module Contract
    module ActiveModel # rubocop:disable Style/Documentation
      def self.included(descendant) # rubocop:disable Metrics/MethodLength
        class << descendant
          def contract(&block) # rubocop:disable Metrics/MethodLength
            caller = self
            @contract = Class.new do
              set_temporary_name("#{caller.inspect.downcase}::contract")
              include ::ActiveModel::API
              include ::ActiveModel::Attributes
              include ::ActiveModel::Validations

              def self.model_name
                ::ActiveModel::Name.new(self, nil, "temp")
              end

              def self.build_for_interactor_validation(ctx)
                contract = new
                declared_attributes = contract.attribute_names.each(&:to_sym)
                context_attributes_to_validate = ctx.slice(declared_attributes)
                contract.assign_attributes(context_attributes_to_validate)
                contract
              end
            end
            @contract.class_exec(&block)
          end
        end
      end

      def validate(ctx)
        self.class.instance_variable_get(:@contract)
            .build_for_interactor_validation(ctx)
            .validate!
      rescue ::ActiveModel::ValidationError => e
        ctx.errors << e.message
      end
    end
  end
end
