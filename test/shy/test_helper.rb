# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "shy/interactor"
require "shy/interactor/contract/active_model"
require "shy/interactor/contract/dry_validation"

require "minitest/autorun"

class InteractorA
  include Shy::Interactor

  def call(ctx)
    ctx[:a] = "Value A"
  end
end

class InteractorB
  include Shy::Interactor

  def call(ctx)
    ctx[:b] = "Value B"
  end
end

class InteractorSum
  include Shy::Interactor

  def call(ctx)
    ctx[:result] = ctx.fetch(:a) + ctx.fetch(:b)
  end
end

class InteractorWithRollback
  include Shy::Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
  end

  def rollback(ctx)
    ctx[:text] = ctx.fetch(:text).reverse
  end
end

class InteractorWithRollbackAndError
  include Shy::Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
    ctx.errors << "An error"
  end

  def rollback(ctx)
    ctx[:text] = ctx[:text].reverse
  end
end

class InteractorWithError
  include Shy::Interactor

  def call(ctx)
    ctx.errors << "An error"
  end
end

class InteractorWithActiveModelContract
  include Shy::Interactor
  include Shy::Interactor::Contract::ActiveModel

  def call(ctx); end

  contract do
    attribute :test
    validates :test, presence: true
  end
end

class InteractorWithDryValidationContract
  include Shy::Interactor
  include Shy::Interactor::Contract::DryValidation

  def call(ctx); end

  contract do
    params do
      required(:test)
    end
  end
end

class InteractorWithManualValidation
  include Shy::Interactor

  def call(ctx); end

  def validate(ctx)
    ctx.errors << "A validation error"
  end
end

class InteractorWithDifferentCallableMethod
  include Shy::Interactor

  def execute(ctx); end

  def callable_method = :execute
end
