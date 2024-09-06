# frozen_string_literal: true

module Shy
  module Interactor
    # Meant to be `extend`ed by another module. This explains why the
    # `included` hook is not defined on `self` as usual
    module Composable
      def included(descendant)
        class << descendant
          def >>(other) = method(:call).public_send(:>>, other)

          def <<(other) = method(:call).public_send(:<<, other)

          def call(ctx = {}) = new.maybe_call(ctx)
        end
      end
    end
  end
end
