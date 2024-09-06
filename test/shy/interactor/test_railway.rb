# frozen_string_literal: true

require "test_helper"

class TestInteractorRailway < Minitest::Test
  include Shy::Interactor::Railway::ResultBuilders

  def test_returns_a_result_monad
    result = RailwayInteractorA.call

    assert_kind_of Shy::Interactor::Result, result
  end

  def test_returns_a_success_monad
    result = RailwayInteractorA.call

    assert_instance_of Shy::Interactor::Result::Success, result
  end

  def test_success_monad_has_predicate_method
    result = RailwayInteractorA.call

    assert_predicate result, :success?
    refute_predicate result, :failure?
  end

  def test_success_can_be_resolved_to_a_value
    result = RailwayInteractorA.call

    assert_respond_to result, :resolve
  end

  def test_success_resolves_to_the_returned_value
    result = RailwayInteractorA.call

    assert_equal "Value A", result.resolve
  end

  def test_returns_a_failure_monad
    result = RailwayInteractorWithError.call

    assert_kind_of Shy::Interactor::Result::Failure, result
  end

  def test_failure_monad_has_predicate_method
    result = RailwayInteractorWithError.call

    assert_predicate result, :failure?
    refute_predicate result, :success?
  end

  def test_failure_can_be_resolved_to_a_value
    result = RailwayInteractorWithError.call

    assert_respond_to result, :resolve
  end

  def test_failure_resolves_to_self
    result = RailwayInteractorWithError.call

    assert_instance_of Shy::Interactor::Result::Failure, result.resolve
  end

  def test_failure_has_a_message
    result = RailwayInteractorWithError.call

    assert_equal "An error", result.message
  end

  def test_calling_with_kwargs_will_produce_an_hash_as_argument
    result = RailwayInteractorSum.call(a: 1, b: 2)

    assert_equal 3, result.resolve
  end

  def test_can_be_called_with_an_arbitrary_argument
    result = RailwayInteractorSumExpectingArray.call([1, 2])

    assert_equal 3, result.resolve
  end

  module ScopeWithActiveRefinements
    using Shy::Interactor::HashRefinements

    module_function

    def run_test
      RailwayInteractorSumStructContext.call({ a: 1, b: 2 }.to_struct)
    end
  end

  def test_can_use_our_refinements_to_produce_a_struct_value
    result = ScopeWithActiveRefinements.run_test

    assert_equal 3, result.resolve
  end

  def test_railway_interactors_can_be_composed
    glue = proc do |result|
      a =  result.resolve
      Success({ a:, b: 10 })
    end

    result = (RailwayInteractorSum >> glue >> RailwayInteractorSum).call(a: 1, b: 2)

    assert_equal 13, result.resolve
  end

  def test_composed_railway_interactors_correctly_fail
    glue = proc do |result|
      a = result.resolve
      Success({ a:, b: 10 })
    end

    result = (RailwayInteractorSum >> glue >> RailwayInteractorWithError >> RailwayInteractorSum).call(a: 1, b: 2)

    assert_predicate result, :failure?
    assert_instance_of RailwayInteractorWithError, result.owner
    assert_equal "An error", result.message
  end

  def test_dry_validation_type_validation
    result = RailwayInteractorWithDryValidationType.call(1)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal "1 violates constraints (type?(String, 1) failed)", result.message
  end

  def test_dry_validation_contract_validation
    result = RailwayInteractorWithDryValidationContract.call(test: 1)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["must be a string"] }, result.message)

    result = RailwayInteractorWithDryValidationContract.call

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["is missing"] }, result.message)
  end
end
