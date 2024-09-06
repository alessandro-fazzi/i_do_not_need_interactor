# frozen_string_literal: true

module Shy
  module Interactor
    module Railway # rubocop:disable Style/Documentation
      extend Composable

      def maybe_call(result = nil) # rubocop:disable Metrics/MethodLength
        return result if result.is_a?(Result::Failure)

        result = result.resolve if result.is_a?(Result::Success)

        validation_result = run_validation(result)
        return validation_result if validation_result.is_a?(Result::Failure)

        result = actually_call(result)

        case result
        in Result::Failure if result.owner.nil?
          # Re-wrap to add the owner
          Result.Failure(result.message, owner: self)
        in Result::Failure | Result::Success
          result
        else
          Result.Success(result, owner: self)
        end
      end

      module ResultBuilders # rubocop:disable Style/Documentation
        private

        def Failure(...) = Shy::Interactor::Result.Failure(...) # rubocop:disable Naming/MethodName

        def Success(...) = Shy::Interactor::Result.Success(...) # rubocop:disable Naming/MethodName
      end
      include ResultBuilders

      private

      def run_validation(result)
        return result unless respond_to?(:validate)

        validate(result)
      end

      def actually_call(result)
        logger.debug [result, "Executed #{self.class}"]

        send(callable_method, result)
      end

      def callable_method = :call

      def logger
        Shy::Interactor.config.logger
      end
    end
  end
end
