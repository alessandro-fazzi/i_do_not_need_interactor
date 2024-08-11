# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"

  gem "activemodel"
  gem "i_do_not_need_interactor", github: "alessandro-fazzi/i_do_not_need_interactor"
  gem "amazing_print"
end

require "active_model"
require "amazing_print"

class DoSomething # rubocop:disable Style/Documentation
  include Interactor
  include Interactor::Contract::ActiveModel

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
