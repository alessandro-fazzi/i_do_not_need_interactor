# frozen_string_literal: true

require "test_helper"

class TestIDoNotNeedInteractor < Minitest::Test
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

  def test_when_doing_a_single_interactor_call_kwargs_could_be_used_to_initialize_context
    outcome = InteractorSum.call(a: 1, b: 41)

    assert_equal 42, outcome[:result]
  end

  def test_when_using_composition_kwargs_could_be_used_to_initialize_context
    outcome = (->(ctx) { ctx } >> InteractorSum).call(a: 1, b: 2)

    assert_equal 3, outcome[:result]
  end

  def test_it_is_possible_to_compose_interactors
    outcome = (InteractorA >> InteractorB >> InteractorSum).call

    assert_equal "Value AValue B", outcome[:result]
  end

  def test_it_is_possible_to_compose_interactors_in_reversed_order
    outcome = (InteractorSum << InteractorB << InteractorA).call

    assert_equal "Value AValue B", outcome[:result]
  end

  def test_it_is_possibile_to_compose_interactor_with_sub_compositions
    outcome = ((InteractorA >> InteractorB) >> InteractorSum).call

    assert_equal "Value AValue B", outcome[:result]
  end

  def test_proc_can_be_used_in_composition
    before_sum = lambda do |ctx|
      ctx[:a] += 1
      ctx
    end
    outcome = (before_sum >> InteractorSum).call(Interactor::Context.new(a: 1, b: 40))

    assert_equal 42, outcome[:result]
  end

  def test_interactor_can_be_rolled_back
    outcome = InteractorWithRollbackAndError.call

    assert_equal "Eleven", outcome[:text]
  end

  def test_interactor_can_be_rolled_back_when_composed
    outcome = (InteractorWithRollback >> InteractorWithError).call

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
      InteractorA >>
      ->(ctx) { ctx[:a] = ctx.fetch(:a).length and ctx } >>
      around.call(InteractorSum)
    ).call(Interactor::Context.new(b: 2))

    assert_equal [7, 2, nil], outcome[:before_around]
    assert_equal [7, 2, 9], outcome[:after_around]
  end

  def test_manual_validation
    outcome = InteractorWithManualValidation.call

    assert_equal ["A validation error"], outcome.errors
  end

  def test_context_knows_which_interactor_has_failed
    outcome = (InteractorA >> InteractorWithError).call

    assert_instance_of InteractorWithError, outcome.failed
  end
end
