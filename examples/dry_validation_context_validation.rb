# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "dry-validation"
  gem "shy-interactor", github: "alessandro-fazzi/shy-interactor"
  gem "amazing_print"
end

require "shy/interactor/contract/dry_validation"
require "amazing_print"

class DoSomething # rubocop:disable Style/Documentation
  include Shy::Interactor
  include Shy::Interactor::Contract::DryValidation

  def call(ctx)
    ctx[:done] = true
  end

  contract do
    schema do
      optional(:done).value(:bool)
      required(:foo).value(:string)
    end
  end
end

result = DoSomething.call(done: false)
if result.success?
  ap result
else
  ap result.errors
end
