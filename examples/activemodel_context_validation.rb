# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "activemodel"
  gem "shy-interactor", github: "alessandro-fazzi/shy-interactor"
  gem "amazing_print"
end

require "active_model"
require "shy/interactor/contract/active_model"
require "amazing_print"

class DoSomething # rubocop:disable Style/Documentation
  include Shy::Interactor
  include Shy::Interactor::Contract::ActiveModel

  def call(ctx)
    ctx[:done] = true
  end

  contract do
    attribute :done, :boolean
    attribute :foo, :string
    validates :foo, presence: true
  end
end

result = DoSomething.call
if result.success?
  ap result
else
  ap result.errors
end
