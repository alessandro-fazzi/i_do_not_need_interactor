# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "i_do_not_need_interactor"
require "i_do_not_need_interactor/contract/active_model"
require "i_do_not_need_interactor/contract/dry_validation"

require "minitest/autorun"

class InteractorA
  include Interactor

  def call(ctx)
    ctx[:a] = "Value A"
  end
end

class InteractorB
  include Interactor

  def call(ctx)
    ctx[:b] = "Value B"
  end
end

class InteractorSum
  include Interactor

  def call(ctx)
    ctx[:result] = ctx.fetch(:a) + ctx.fetch(:b)
  end
end

class InteractorWithRollback
  include Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
  end

  def rollback(ctx)
    ctx[:text] = ctx.fetch(:text).reverse
  end
end

class InteractorWithRollbackAndError
  include Interactor

  def call(ctx)
    ctx[:text] = "nevelE"
    ctx.errors << "An error"
  end

  def rollback(ctx)
    ctx[:text] = ctx[:text].reverse
  end
end

class InteractorWithError
  include Interactor

  def call(ctx)
    ctx.errors << "An error"
  end
end

class InteractorWithActiveModelContract
  include Interactor
  include Interactor::Contract::ActiveModel

  def call(ctx); end

  contract do
    attribute :test
    validates :test, presence: true
  end
end

class InteractorWithDryValidationContract
  include Interactor
  include Interactor::Contract::DryValidation

  def call(ctx); end

  contract do
    params do
      required(:test)
    end
  end
end

class InteractorWithManualValidation
  include Interactor

  def call(ctx); end

  def validate(ctx)
    ctx.errors << "A validation error"
  end
end

class InteractorWithDifferentCallableMethod
  include Interactor

  def execute(ctx); end

  def callable_method = :execute
end
