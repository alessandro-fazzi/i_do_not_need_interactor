# frozen_string_literal: true

require_relative "test_contract_behavior"

class TestDryValidationContract < Minitest::Test
  include ::TestContractBehavior

  def setup
    super
    @subject = InteractorWithDryValidationContract
    @subject_expected_error_message = { test: ["is missing"] }
  end

  def test_type_validation
    result = RailwayInteractorWithDryValidationType.call(1)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal "1 violates constraints (type?(String, 1) failed)", result.message
  end

  def test_railway_contract_validation
    result = RailwayInteractorWithDryValidationContract.call(test: 1)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["must be a string"] }, result.message)

    result = RailwayInteractorWithDryValidationContract.call

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["is missing"] }, result.message)
  end

  def test_railway_contract_validation_when_result_is_a_struct
    result = Shy::Interactor::Context.Struct(test: 1)
    result = RailwayInteractorWithDryValidationContract.call(result)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["must be a string"] }, result.message)

    result = RailwayInteractorWithDryValidationContract.call

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_equal({ test: ["is missing"] }, result.message)
  end

  def test_railway_validation_adds_owner_to_failure_monad_when_it_fails
    result = RailwayInteractorWithDryValidationType.call(1)

    assert_instance_of Shy::Interactor::Result::Failure, result
    assert_instance_of RailwayInteractorWithDryValidationType, result.owner
  end
end
