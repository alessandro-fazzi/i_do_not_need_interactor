# frozen_string_literal: true

require_relative "test_contract_behavior"

class TestDryValidationContract < Minitest::Test
  include ::TestContractBehavior

  def setup
    @subject = InteractorWithDryValidationContract
    @subject_expected_error_message = { test: ["is missing"] }
  end
end
