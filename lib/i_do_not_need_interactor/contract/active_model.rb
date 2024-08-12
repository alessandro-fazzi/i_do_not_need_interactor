# frozen_string_literal: true

require "active_model"

module IDoNotNeedInteractor
  module Contract
    module ActiveModel # rubocop:disable Style/Documentation
      def self.included(descendant) # rubocop:disable Metrics/MethodLength
        class << descendant
          def contract(&block)
            caller = self
            @contract = Class.new do
              set_temporary_name("#{caller.inspect.downcase}::contract")
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
      rescue ::ActiveModel::ValidationError, ::ActiveModel::UnknownAttributeError => e
        ctx.errors << e.message
      end
    end
  end
end
