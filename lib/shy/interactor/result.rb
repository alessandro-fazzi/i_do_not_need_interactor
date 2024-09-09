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

      def success? = raise NotImplementedError

      def failure? = !success?

      def resolve = raise NotImplementedError

      # def rewrap(result)
      #   self.class
      # end

      class Success < self # rubocop:disable Style/Documentation
        def initialize(value, owner: nil)
          super(owner:)
          @value = value
        end

        def resolve = @value

        def success? = true
      end

      class Failure < self # rubocop:disable Style/Documentation
        attr_reader :message

        def initialize(message, owner: nil)
          super(owner:)
          @message = message
        end

        def resolve = self

        def success? = false
      end
    end
  end
end
