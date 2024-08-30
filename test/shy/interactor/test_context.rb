# frozen_string_literal: true

require "test_helper"

class TestContext < Minitest::Test
  def setup
    @subject = Shy::Interactor::Context
  end

  def test_can_build_a_context_hash
    assert_kind_of Hash, @subject.Hash()
    assert_kind_of Shy::Interactor::ActsAsContext, @subject.Hash()
  end

  def test_can_build_a_context_hash_with_prefilled_members
    context = @subject.Hash(a: "hash")

    assert_equal "hash", context[:a]
  end

  def test_can_build_a_context_struct
    assert_kind_of Struct, @subject.Struct()
  end

  def test_can_build_context_struct_with_prefilled_members
    context = @subject.Struct(a: "hash")

    assert_equal "hash", context.a
  end

  def test_can_add_new_methods_to_context_struct_at_build_time
    context = @subject.Struct(a: "hash") do
      def b = "bee" # rubocop:disable Lint/NestedMethodDefinition
    end

    assert_equal "bee", context.b
  end
end
