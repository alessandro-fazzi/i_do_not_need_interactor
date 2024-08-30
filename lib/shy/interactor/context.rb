# frozen_string_literal: true

module Shy
  module Interactor
    module ActsAsContext # rubocop:disable Style/Documentation
      attr_reader :errors, :_executed

      def initialize(**)
        super
        @errors = []
        @_executed = []
      end

      def register(object)
        @_executed << object
      end

      def success? = errors.empty?

      def failure? = !success?

      def failed = _executed.find { _1.failed == true }
    end

    class Context # rubocop:disable Style/Documentation
      using Shy::Interactor::HashRefinements

      def self.Struct(**initial_values, &) # rubocop:disable Naming/MethodName
        initial_values.to_context(&)
      end

      def self.Hash(**initial_values)
        Hash.new(**initial_values)
      end

      class Hash < ::Hash # rubocop:disable Style/Documentation
        include ActsAsContext

        def initialize(**initial_values)
          super()
          merge! initial_values
        end
      end
    end
  end
end
