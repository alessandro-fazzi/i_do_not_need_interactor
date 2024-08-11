# frozen_string_literal: true

module IDoNotNeedInteractor
  class Context < Hash # rubocop:disable Style/Documentation
    attr_reader :errors, :_executed

    def initialize(**initial_values)
      super()
      @errors = []
      @_executed = []
      merge! initial_values
    end

    def register(object)
      @_executed << object
    end

    def success? = errors.empty?

    def failure? = !success?

    def failed = _executed.find { _1.failed == true }
  end
end
