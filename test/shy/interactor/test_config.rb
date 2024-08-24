# frozen_string_literal: true

require "test_helper"

class TestConfig < Minitest::Test
  include TestConfigHelper

  def test_the_main_module_has_a_config_object
    assert_instance_of Shy::Interactor::Config, Shy::Interactor.config
  end

  def test_default_logger_is_configured_by_default
    assert_instance_of Shy::Interactor::Logger, Shy::Interactor.config.logger
  end

  def test_configuration_can_be_updated_with_configure_convenience_method
    assert_instance_of Shy::Interactor::Logger, Shy::Interactor.config.logger

    Shy::Interactor.configure do |config|
      config.logger = "updated"
    end

    assert_equal "updated", Shy::Interactor.config.logger
  end

  def test_configuration_can_be_updated_directly_through_accessor
    assert_instance_of Shy::Interactor::Logger, Shy::Interactor.config.logger

    Shy::Interactor.config.logger = "updated"

    assert_equal "updated", Shy::Interactor.config.logger
  end

  def test_configuration_is_freezable # rubocop:disable Metrics/MethodLength
    Shy::Interactor.configure do |config|
      config.logger = "updated"
      config.freeze
    end

    assert_raises FrozenError do
      Shy::Interactor.configure do |config|
        config.logger = "foo"
      end
    end

    assert_raises FrozenError do
      Shy::Interactor.config.logger = "foo"
    end
  end
end
