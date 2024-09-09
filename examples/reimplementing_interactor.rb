# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "shy-interactor", github: "alessandro-fazzi/shy-interactor"
end

class Cat # rubocop:disable Style/Documentation
  def self.let_it_leave(food:)
    (
      Eat >> Eat >> Eat >>
      Walk >>
      Poop
    ).call(eaten: [], food:)
  end

  class Walk # rubocop:disable Style/Documentation
    include Shy::Interactor

    def call(ctx)
      return ctx if ctx[:eaten].size < 2

      ctx[:walked] = true
      ctx[:eaten].shift
    end
  end

  class Eat # rubocop:disable Style/Documentation
    include Shy::Interactor

    def call(ctx)
      return ctx if ctx[:eaten].size >= 2

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

outcome = Cat.let_it_leave(food: "fish")
p outcome.success?
p outcome
