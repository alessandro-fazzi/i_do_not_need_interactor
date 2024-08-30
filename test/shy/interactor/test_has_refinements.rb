# frozen_string_literal: true

require "test_helper"

class TestHashRefinements < Minitest::Test
  using Shy::Interactor::HashRefinements

  def setup
    @hash = { a: "hash" }
  end

  def test_can_transform_an_hash_into_a_struct
    struct = @hash.to_struct

    assert_kind_of Struct, struct
    assert_equal [:a], struct.members
  end

  def test_can_transform_an_hash_into_a_context
    struct = @hash.to_context

    assert_kind_of Struct, struct
    assert_kind_of Shy::Interactor::ActsAsContext, struct
    assert_equal [:a], struct.members
  end

  def test_can_add_methods_while_creating_the_struct
    struct = @hash.to_struct do
      def foo = "foo" # rubocop:disable Lint/NestedMethodDefinition
    end

    assert_equal "foo", struct.foo
  end

  def test_can_add_methods_while_creating_the_context
    struct = @hash.to_context do
      def foo = "foo" # rubocop:disable Lint/NestedMethodDefinition
    end

    assert_equal "foo", struct.foo
  end
end
