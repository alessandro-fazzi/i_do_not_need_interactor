# frozen_string_literal: true

module Shy
  module Interactor
    Config = Struct.new(:logger, keyword_init: true) do
      class << self
        def build_with_defaults
          new(
            logger: Logger.new
          )
        end

        def build_for_test(device = File::NULL)
          new(
            logger: Logger.new(device)
          )
        end
      end

      def configure(&block)
        block.call(self)
      end
    end
  end
end
