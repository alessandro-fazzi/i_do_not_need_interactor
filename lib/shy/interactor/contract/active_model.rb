# frozen_string_literal: true

require "active_model"

module Shy
  module Interactor
    module Contract
      module ActiveModel # rubocop:disable Style/Documentation
        def self.included(descendant) # rubocop:disable Metrics/MethodLength
          class << descendant
            def contract(&) # rubocop:disable Metrics/MethodLength
              caller = self
              @contract = Class.new do
                set_temporary_name("#{caller.inspect.downcase}::contract")
                include ::ActiveModel::API
                include ::ActiveModel::Attributes
                include ::ActiveModel::Validations

                def self.model_name
                  ::ActiveModel::Name.new(self, nil, "temp")
                end

                def self.build_for_interactor_validation(hash_or_struct_ctx)
                  contract = new
                  declared_attributes = contract.attribute_names.each(&:to_sym)
                  context_attributes_to_validate = hash_or_struct_ctx.to_h.slice(declared_attributes)
                  contract.assign_attributes(context_attributes_to_validate)
                  contract
                end
              end
              @contract.class_exec(&)
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
end
