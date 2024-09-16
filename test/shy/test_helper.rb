# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "shy/interactor"
require "shy/interactor/contract/active_model"
require "shy/interactor/contract/dry_validation"

require "minitest/autorun"

Shy::Interactor.config = Shy::Interactor::Config.build_for_test

module TestConfigHelper
  def setup
    super
    Shy::Interactor.config = Shy::Interactor::Config.build_for_test
  end

  def teardown
    Shy::Interactor.config = Shy::Interactor::Config.build_for_test
    super
  end
end

module TestLoggingHelper
  include TestConfigHelper # this module will be responsible for a pristine config in teardown

  EXPECTED_FIXED_TIME = Time.at(0).utc.to_s

  def teardown
    @log = nil
    super
  end

  private

  def stub_logger(&block)
    log_device_double = StringIO.new
    Shy::Interactor.config = Shy::Interactor::Config.build_for_test(log_device_double)

    Time.stub :now, Time.at(0).utc do
      block.call
    end

    log_device_double.close_write
    log_device_double.rewind
    @log = lines = log_device_double.readlines
    log_device_double.close
    lines
  end

  def assert_log_matches(message:, context: nil, times: nil) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    count = @log.count do |log_line|
      message_matched = case message
                        when String then log_line.match?("message=\"#{message}\"")
                        when Regexp then log_line.match?(message)
                        else false
                        end
      context_matched = case context
                        when String, Regexp then log_line.match?(context)
                        when Hash then log_line.match?(context.to_s)
                        else false
                        end

      next message_matched && context_matched if context

      message_matched
    end

    custom_error_message = lambda do
      message = if context
                  "Expected \"#{message}\" with context \"#{context}\" to appear #{times} times in log messages, " \
                    "but count was #{count}"
                else
                  "Expected \"#{message}\" to appear #{times} times in log messages, but count was #{count}"
                end
      message = <<~MESSAGE
        "#{message}. Log content:


        #{@log.join}

      MESSAGE
    end

    if times
      assert_equal(times, count, custom_error_message)
      return
    end

    assert_operator count, :>, 0
  end
end

class InteractorA
  include Shy::Interactor

  def call(ctx)
    ctx[:a] = "Value A"
  end
end

class RailwayInteractorA
  include Shy::Interactor::Railway

  def call(_result)
    "Value A"
  end
end

class InteractorB
  include Shy::Interactor

  def call(ctx)
    ctx[:b] = "Value B"
  end
end

class InteractorSum
  include Shy::Interactor

  def call(ctx)
    ctx[:result] = ctx.fetch(:a) + ctx.fetch(:b)
  end
end

class RailwayInteractorSum
  include Shy::Interactor::Railway

  def call(result)
    result.fetch(:a) + result.fetch(:b)
  end
end

class RailwayInteractorSumExpectingArray
  include Shy::Interactor::Railway

  def call(result)
    a, b = result
    a + b
  end
end

class InteractorSumStructContext
  include Shy::Interactor

  def call(ctx)
    ctx.result = ctx.a + ctx.b
  end
end

class RailwayInteractorSumStructContext
  include Shy::Interactor::Railway

  def call(result)
    result.a + result.b
  end
end

class InteractorWithRollback
  include Shy::Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
  end

  def rollback(ctx)
    ctx[:text] = ctx.fetch(:text).reverse
  end
end

class InteractorWithRollbackAndError
  include Shy::Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
    ctx.errors << "An error"
  end

  def rollback(ctx)
    ctx[:text] = ctx[:text].reverse
  end
end

class InteractorWithError
  include Shy::Interactor

  def call(ctx)
    ctx.errors << "An error"
  end
end

class RailwayInteractorWithError
  include Shy::Interactor::Railway

  def call(_result)
    Failure("An error")
  end
end

class InteractorWithActiveModelContract
  include Shy::Interactor
  include Shy::Interactor::Contract::ActiveModel

  contract do
    attribute :test
    validates :test, presence: true
  end

  def call(ctx); end
end

class InteractorWithDryValidationContract
  include Shy::Interactor
  include Shy::Interactor::Contract::DryValidation

  contract do
    params do
      required(:test)
    end
  end

  def call(ctx); end
end

class RailwayInteractorWithDryValidationContract
  include Shy::Interactor::Railway
  include Shy::Interactor::Contract::DryValidation

  contract do
    params do
      required(:test).value(:string)
    end
  end

  def call(ctx); end
end

class RailwayInteractorWithDryValidationType
  include Shy::Interactor::Railway
  include Shy::Interactor::Contract::DryValidation

  validate ->(result) { Types::Strict::String[result] }

  def call(result); end
end

class InteractorWithManualValidation
  include Shy::Interactor

  def call(ctx); end

  def validate(ctx)
    ctx.errors << "A validation error"
  end
end

class RailwayInteractorWithManualValidation
  include Shy::Interactor::Railway

  def call(result); end

  def validate(_result)
    Failure("A validation error")
  end
end

class InteractorWithDifferentCallableMethod
  include Shy::Interactor

  def execute(ctx); end

  def callable_method = :execute
end
