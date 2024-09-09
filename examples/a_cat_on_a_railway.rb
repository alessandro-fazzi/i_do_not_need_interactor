# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "dry-validation"
  gem "shy-interactor", github: "alessandro-fazzi/shy-interactor"
end

require "shy/interactor/contract/dry_validation"

class Cat # rubocop:disable Style/Documentation
  def self.LetItLive(food:) # rubocop:disable Naming/MethodName
    (
      Eat >> Eat >> Eat >>
      Walk >>
      Poop
    ).call(food:, eaten: [])
  end

  def self.WillFailBecauseSated(food:) # rubocop:disable Naming/MethodName
    (
      Eat >>
      Walk >>
      Poop
    ).call(food:, eaten: [food, food, food])
  end

  def self.WillFailBecauseHungry(food:) # rubocop:disable Naming/MethodName
    (
      Walk >>
      Poop
    ).call(food:, eaten: [])
  end

  class Eat # rubocop:disable Style/Documentation
    include Shy::Interactor::Railway
    include Shy::Interactor::Contract::DryValidation

    contract do
      schema do
        required(:food).value(:string)
        required(:eaten).value(:array)
      end

      rule(:eaten) do
        key.failure("The cat is sated thus won't eat anything") if values[:eaten].size >= 3
      end
    end

    def call(result)
      result[:eaten] << result[:food]

      result
    end
  end

  class Walk # rubocop:disable Style/Documentation
    include Shy::Interactor::Railway
    include Shy::Interactor::Contract::DryValidation

    contract do
      schema do
        required(:eaten).value(:array)
      end

      rule(:eaten) do
        key.failure("The cat is hungry thus it won't walk.") if values[:eaten].empty?
      end
    end

    def call(result)
      result[:eaten].shift
      result[:eaten]
    end
  end

  class Poop # rubocop:disable Style/Documentation
    include Shy::Interactor::Railway
    include Shy::Interactor::Contract::DryValidation

    validate ->(result) { Types::Strict::Array.constrained(min_size: 1)[result] }

    def call(result)
      p "Meow"

      []
    end
  end
end

p Cat.LetItLive(food: "fish")
p Cat.WillFailBecauseSated(food: "fish")
p Cat.WillFailBecauseHungry(food: "fish")
