# frozen_string_literal: true

require "test_helper"

class TestIDoNotNeedInteractor < Minitest::Test
  class InteractorA
    include Interactor

    def call(ctx)
      ctx[:a] = "Value A"
    end
  end

  class InteractorB
    include Interactor

    def call(ctx)
      ctx[:b] = "Value B"
    end
  end

  class InteractorSum
    include Interactor

    def call(ctx)
      ctx[:result] = ctx.fetch(:a) + ctx.fetch(:b)
    end
  end

  class InteractorWithRollback
    include Interactor

    def call(ctx)
      ctx[:text] = "nevelE"
    end

    def rollback(ctx)
      ctx[:text] = ctx.fetch(:text).reverse
    end
  end

  class InteractorWithRollbackAndError
    include Interactor

    def call(ctx)
      ctx[:text] = "nevelE"
      ctx.errors << "An error"
    end

    def rollback(ctx)
      ctx[:text] = ctx[:text].reverse
    end
  end

  class InteractorWithError
    include Interactor

    def call(ctx)
      ctx.errors << "An error"
    end
  end

  class InteractorWithActiveModelContract
    include Interactor
    include IDoNotNeedInteractor::Contract::ActiveModel

    def call(ctx); end

    contract do
      attribute :test
      validates :test, presence: true
    end
  end

  class InteractorWithDryValidationContract
    include Interactor
    include IDoNotNeedInteractor::Contract::DryValidation

    def call(ctx); end

    contract do
      params do
        required(:test)
      end
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::IDoNotNeedInteractor::VERSION
  end

  def test_main_module_is_aliased_as_interactor
    assert Module.const_defined? "Interactor"
  end

  def test_an_interactor_returns_a_result
    assert_kind_of Interactor::Context, InteractorA.call
  end

  def test_context_is_mutated_by_the_interactor
    outcome = InteractorA.call

    assert_equal "Value A", outcome[:a]
  end

  def test_it_is_possible_to_call_it_with_an_existent_context
    outcome = InteractorSum.call(Interactor::Context.new(a: 1, b: 41))

    assert_equal 42, outcome[:result]
  end

  def test_it_is_possible_to_compose_interactors
    outcome = (InteractorA.pipe >> InteractorB.pipe >> InteractorSum.pipe).call

    assert_equal "Value AValue B", outcome[:result]
  end

  def test_it_is_possibile_to_compose_interactor_with_sub_compositions
    outcome = ((InteractorA.pipe >> InteractorB.pipe) >> InteractorSum.pipe).call

    assert_equal "Value AValue B", outcome[:result]
  end

  def test_proc_can_be_used_in_composition
    before_sum = lambda do |ctx|
      ctx[:a] += 1
      ctx
    end
    outcome = (before_sum >> InteractorSum.pipe).call(Interactor::Context.new(a: 1, b: 40))

    assert_equal 42, outcome[:result]
  end

  def test_interactor_can_be_rolled_back
    outcome = InteractorWithRollbackAndError.call

    assert_equal "Eleven", outcome[:text]
  end

  def test_interactor_can_be_rolled_back_when_composed
    outcome = (InteractorWithRollback.pipe >> InteractorWithError.pipe).call

    assert_equal "Eleven", outcome[:text]
  end

  def test_outcome_will_be_a_failure_when_an_error_occurred
    outcome = InteractorWithError.call

    assert_predicate outcome, :failure?
    assert_equal ["An error"], outcome.errors
  end

  def test_outcome_will_be_a_success_when_no_error_occurred
    outcome = InteractorA.call

    assert_predicate outcome, :success?
  end

  def test_with_proc_is_possible_to_simulate_an_around_hook # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    around = lambda do |interactor|
      lambda do |ctx|
        ctx[:before_around] = [ctx[:a], ctx[:b], ctx[:result]]
        interactor.call(ctx)
        ctx[:after_around] = [ctx[:a], ctx[:b], ctx[:result]]

        ctx
      end
    end
    outcome = around.call(InteractorSum).call(Interactor::Context.new(a: 1, b: 2))

    assert_equal [1, 2, nil], outcome[:before_around]
    assert_equal [1, 2, 3], outcome[:after_around]
  end

  def test_with_proc_is_possible_to_simulate_an_around_hook_also_in_composition # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    around = lambda do |interactor|
      lambda do |ctx|
        ctx[:before_around] = [ctx[:a], ctx[:b], ctx[:result]]
        interactor.call(ctx)
        ctx[:after_around] = [ctx[:a], ctx[:b], ctx[:result]]

        ctx
      end
    end
    outcome = (
      InteractorA.pipe >>
      ->(ctx) { ctx[:a] = ctx.fetch(:a).length and ctx } >>
      around.call(InteractorSum)
    ).call(Interactor::Context.new(b: 2))

    assert_equal [7, 2, nil], outcome[:before_around]
    assert_equal [7, 2, 9], outcome[:after_around]
  end

  def test_contract_active_model_integration
    outcome = InteractorWithActiveModelContract.call

    assert_equal ["Validation failed: Test can't be blank"], outcome.errors
  end

  def test_contract_dry_validation_integration
    outcome = InteractorWithDryValidationContract.call

    assert_equal [{ test: ["is missing"] }], outcome.errors
  end
end
