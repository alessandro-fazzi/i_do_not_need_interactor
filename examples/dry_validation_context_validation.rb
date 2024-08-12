# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "dry-validation"
  gem "i_do_not_need_interactor", github: "alessandro-fazzi/i_do_not_need_interactor"
  gem "amazing_print"
end

require "dry-validation"
require "i_do_not_need_interactor/contract/dry_validation"
require "amazing_print"

class DoSomething # rubocop:disable Style/Documentation
  include Interactor
  include Interactor::Contract::DryValidation

  def call(ctx)
    ctx[:done] = true
  end

  contract do
    params do
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
