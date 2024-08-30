# frozen_string_literal: true

module Shy
  module Interactor
    module HashRefinements # rubocop:disable Style/Documentation
      refine Hash do
        def to_struct(&block)
          struct = Struct.new(*keys, keyword_init: true, &block)
          struct.new(**self)
        end

        def to_context(&block)
          struct = Struct.new(*keys, keyword_init: true, &block)
          struct.include(Shy::Interactor::ActsAsContext)
          struct.new(**self)
        end
      end
    end
  end
end
