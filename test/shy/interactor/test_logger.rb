# frozen_string_literal: true

require "test_helper"

class TestLogger < Minitest::Test
  include TestLoggingHelper

  def test_log_format
    log = stub_logger do
      InteractorA.call(foo: :bar)
    end

    assert_match(
      /\AD, \[1970-01-01T00:00:00.000000 #[0-9]+\] DEBUG -- Shy::Interactor: message="Executed InteractorA" context="{:foo=>:bar}"\Z/, # rubocop:disable Layout/LineLength
      log.first
    )
  end

  def test_each_execution_is_logged
    stub_logger do
      (InteractorA >> InteractorB).call
    end

    assert_log_matches(
      message: /Executed Interactor(A|B)/,
      times: 2
    )
  end

  def test_context_is_logged_too
    stub_logger do
      InteractorA.call(foo: :bar)
    end

    assert_log_matches(
      message: "Executed InteractorA",
      context: /:foo=>:bar/,
      times: 1
    )
  end
end
