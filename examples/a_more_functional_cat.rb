# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "shy-interactor", github: "alessandro-fazzi/shy-interactor"
end

module Heterotroph # rubocop:disable Style/Documentation
  def hungry? = eaten.size < 2

  def sated? = eaten.size >= 2
end

class Cat # rubocop:disable Style/Documentation
  def self.LetItLive(food:) # rubocop:disable Naming/MethodName
    context = Shy::Interactor::Context.Struct(
      food:,
      eaten: [],
      walked: false
    ) do
      extend Heterotroph
    end

    (
      Eat >> Eat >> Eat >>
      Walk >>
      Poop
    ).call(context)
  end

  class Walk # rubocop:disable Style/Documentation
    include Shy::Interactor

    def call(ctx)
      return ctx if ctx.hungry?

      ctx[:walked] = true
      ctx[:eaten].shift
    end
  end

  class Eat # rubocop:disable Style/Documentation
    include Shy::Interactor

    def call(ctx)
      return ctx if ctx.sated?

      ctx[:eaten] << ctx[:food]
    end
  end

  class Poop # rubocop:disable Style/Documentation
    include Shy::Interactor

    def call(ctx)
      ctx[:eaten].replace []
      p "Meow"
    end
  end
end

outcome = Cat.LetItLive(food: "fish")
p outcome.success?
p outcome
