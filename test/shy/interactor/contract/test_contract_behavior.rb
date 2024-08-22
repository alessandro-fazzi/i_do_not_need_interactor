# frozen_string_literal: true

module TestContractBehavior
  def test_respond_to_validate
    assert_respond_to @subject.new, :validate
  end

  def test_validation
    outcome = @subject.call

    assert_equal [@subject_expected_error_message], outcome.errors
  end

  def test_validates_only_declared_attributes
    undeclared_attribute = { foo: 1 }
    outcome = @subject.call(undeclared_attribute)

    assert_equal [@subject_expected_error_message], outcome.errors
  end

  def test_validation_in_composition
    outcome = (InteractorA >> @subject).call

    assert_predicate outcome, :failure?
    assert_equal [@subject_expected_error_message], outcome.errors
    assert_equal "Value A", outcome[:a]
  end

  def test_validation_fails_the_context
    outcome = (@subject >> InteractorA).call

    assert_predicate outcome, :failure?
    assert_equal [@subject_expected_error_message], outcome.errors
    assert_nil outcome[:a] # InteractorA wasn't executed
  end

  def test_validation_in_composition_should_trigger_rollback_for_previous_interactors
    outcome = (InteractorWithRollback >> @subject).call

    assert_predicate outcome, :failure?
    assert_equal [@subject_expected_error_message], outcome.errors
    assert_equal "Eleven", outcome[:text]
  end
end
