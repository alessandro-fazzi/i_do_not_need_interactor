# frozen_string_literal: true

module Shy
  module Interactor
    class Result # rubocop:disable Style/Documentation
      attr_reader :owner

      def self.Success(...) = Success.new(...)

      def self.Failure(...) = Failure.new(...)

      def initialize(owner:)
        @owner = owner
      end

      def success? = is_a?(Success)

      def failure? = is_a?(Failure)

      def resolve = raise NotImplementedError

      # def rewrap(result)
      #   self.class
      # end

      class Success < self # rubocop:disable Style/Documentation
        using Shy::Interactor::HashRefinements

        attr_reader :value

        def initialize(value, owner: nil)
          super(owner:)
          @value = value
        end

        def resolve = value
      end

      class Failure < self # rubocop:disable Style/Documentation
        attr_reader :message

        def initialize(message, owner: nil)
          super(owner:)
          @message = message
        end

        def resolve = self
      end
    end
  end
end
