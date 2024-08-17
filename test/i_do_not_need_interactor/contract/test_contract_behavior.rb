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

    assert_equal [@subject_expected_error_message], outcome.errors
  end

  def test_validation_fails_the_context
    outcome = (@subject >> InteractorA).call

    assert_equal [@subject_expected_error_message], outcome.errors
    assert_nil outcome[:a]
    assert_instance_of @subject, outcome.failed
  end
end
