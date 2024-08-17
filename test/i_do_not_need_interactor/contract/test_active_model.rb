# frozen_string_literal: true

require_relative "test_contract_behavior"

class TestActiveModelContract < Minitest::Test
  include ::TestContractBehavior

  def setup
    super
    @subject = InteractorWithActiveModelContract
    @subject_expected_error_message = "Validation failed: Test can't be blank"
  end
end
