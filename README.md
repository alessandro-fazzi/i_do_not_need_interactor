> [!WARNING]
> This is a POC built to support a discussion between colleagues.
> It's born unmaintained by its own nature.

# Shy::Interactor

I think `interactor` gem could be substituted with 50 lines of ruby and a moderate use of functional patterns.

Long live Interactor.

## Installation

> [!NOTE]
> This gem is not and will not be published on rubygems since it's just a POC

Install the gem and add to the application's Gemfile by executing:

    $ bundle add shy-interactor --github "alessandro-fazzi/shy-interactor"

## Usage

Tests should demonstrate usage. Some interesting spotlights follows.

### Validation

> [!TIP]
> In the `examples/` folder the are some runnable examples of validated interactors.

2 plugins are shipped to validate the Context. You have to manually
`require` them and add dependencies to your bundle:

```bash
bundle add activemodel

require "shy-interactor/contract/active_model"
```

or

```bash
bundle add dry-validation

require "shy-interactor/contract/dry_validation"
```

Here's an example

```ruby
class InteractorWithActiveModelContract
  include Shy::Interactor
  include Shy::Interactor::Contract::ActiveModel

  def call(ctx); end

  contract do
    attribute :test
    validates :test, presence: true
  end
end
```

Inside the `contract` block you have access to `ActiveModel::Attributes` and
`ActiveModel::Validations` methods and you're also free to overdo: the block is
evaluated in the context of a class. I advise to keep things simple; `attribute`
and `validates` should be all you need in order to do basic validation.

`contract` will dynamically create a class, will create the object initializing
it with the context's key/value pairs also declared as attributes in the contract
(in composition a single interactor can't be responsible to validate the whole
context, but just the data it needs), then it will be validated.

If the context is invalid it's errors messages will be copied into context's
`errors`, thus making it a failed one.

Using `dry-validation` is more straightforward under the hood, even if the DSL
takes the interface equivalent:

```ruby
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
```

The `contract` block will dynamically create a `Dry::Validation::Contract` class,
spawn an object from it then will `.call` the object passing in the context.
`contract`'s block will be evaluated inside the `Dry::Validation::Contract` so
you should have access to all its goodies.

You can also do manual validation w/o the need to add additional dependencies.
Interactors are validated if they respond to `#validate` (accepting context as sole
argument):

```ruby
class InteractorWithManualValidation
  include Shy::Interactor

  def call(ctx); end

  def validate(ctx)
    ctx.errors << "A validation error"
  end
end
```

> [!IMPORTANT]
> Validation is done before interactor execution but only if the received context
> is `#success?`.
>
> If the validation fails the interactor is not executed.

### Composition

While other libraries introduce concepts to "chain" more interactors together, this
POC relies on Ruby's own functional composition.

```ruby
(
  ->(number) { number += 1 } >>
  ->(number) { number += 1 } >>
  ->(number) { number += 1 }
).call(0)

# => 3
```

Including `Shy::Interactor` module will make the descendant respond to `#>>` method (on class)
like a callable object handling the _context_. Moreover any callable object accepting a sole
argument (the _context_) can be added in the composition chain.

> [!IMPORTANT]
> When using an arbitrary callable object, be sure to always return the context at the
> end of its execution

```ruby
log_the_failure = lambda do |ctx|
  return ctx if ctx.success?

  App.logger.debug("This was the context: #{ctx}. Failed interactor was: #{ctx.failed}")

  ctx
end

(
  InteractorA >>
  InteractorSum >>
  log_the_failure
).call(b: 2)
```

> [!WARNING]
> As you noticed in the last snippet custom callable objects are responsible to determine
> if they should or should not execute given current _context_'s state.
> You're on your own. But it's just ruby.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alessandro-fazzi/shy-interactor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alessandro-fazzi/shy-interactor/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shy::Interactor project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alessandro-fazzi/shy-interactor/blob/main/CODE_OF_CONDUCT.md).
