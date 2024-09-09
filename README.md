> [!WARNING]
> This is a POC built to support a discussion between colleagues.
> It's born unmaintained by its own nature.

# Shy::Interactor

Refer to the [narration/README.md](narration document) for the long,
follow-through discussion.

## Installation

> [!NOTE]
> This gem is not and will not be published on rubygems since it's just a POC

Install the gem and add to the application's Gemfile by executing:

    $ bundle add shy-interactor --github "alessandro-fazzi/shy-interactor"

## What does it do

Building interactors (service objects) with different capabilities and composing
them together.

- *Interactor*-like interactors, but without using `OpenStruct`
- creating context as `Struct` with dry-ed syntax
  - creating a struct context starting from a `Hash` (with refinements)
  - adding methods to struct context even using the dry-ed syntax or hash
    refinements conversion method
- validating context
  - with active model
    - hash context
    - struct context
  - with dry-validation
    - hash context
    - struct context
    - arbitrary context
- interactors composition (orchestration) without the use of a dedicated class,
  but using ruby's own functional composition
- railway interactors
  - basic Result::Success/Result::Failure monads
  - owner tracking in Result (useful for knowing which interactor has failed
    in a pipeline)
  -

## Usage

Tests should demonstrate usage.

```ruby
TestContext#test_can_build_a_context_hash
TestContext#test_can_add_new_methods_to_context_struct_at_build_time
TestContext#test_can_build_a_context_struct
TestContext#test_can_build_context_struct_with_prefilled_members
TestContext#test_can_build_a_context_hash_with_prefilled_members
TestInteractorRailway#test_railway_interactors_can_be_composed
TestInteractorRailway#test_returns_a_success_monad
TestInteractorRailway#test_composed_railway_interactors_correctly_fail
TestInteractorRailway#test_success_can_be_resolved_to_a_value
TestInteractorRailway#test_calling_with_kwargs_will_produce_an_hash_as_argument
TestInteractorRailway#test_failure_has_a_message
TestInteractorRailway#test_failure_monad_has_predicate_method
TestInteractorRailway#test_failure_can_be_resolved_to_a_value
TestInteractorRailway#test_failure_resolves_to_self
TestInteractorRailway#test_returns_a_result_monad
TestInteractorRailway#test_can_be_called_with_an_arbitrary_argument
TestInteractorRailway#test_returns_a_failure_monad
TestInteractorRailway#test_success_monad_has_predicate_method
TestInteractorRailway#test_success_resolves_to_the_returned_value
TestInteractorRailway#test_can_use_our_refinements_to_produce_a_struct_as_initial_result_and_it_works
TestInteractorRailway#test_railway_interactor_does_not_support_rollback
TestHashRefinements#test_can_add_methods_while_creating_the_struct
TestHashRefinements#test_can_add_methods_while_creating_the_context
TestHashRefinements#test_can_transform_an_hash_into_a_struct
TestHashRefinements#test_can_transform_an_hash_into_a_context
TestConfig#test_configuration_can_be_updated_with_configure_convenience_method
TestConfig#test_configuration_can_be_updated_directly_through_accessor
TestConfig#test_default_logger_is_configured_by_default
TestConfig#test_the_main_module_has_a_config_object
TestConfig#test_configuration_is_freezable
TestLogger#test_each_execution_is_logged
TestLogger#test_context_is_logged_too
TestLogger#test_log_format
TestActiveModelContract#test_validation_fails_the_context
TestActiveModelContract#test_validation_in_composition
TestActiveModelContract#test_validates_only_declared_attributes
TestActiveModelContract#test_respond_to_validate
TestActiveModelContract#test_validation_in_composition_should_trigger_rollback_for_previous_interactors
TestActiveModelContract#test_validation_works_when_context_is_a_struct
TestActiveModelContract#test_validation
TestInteractor#test_proc_can_be_used_in_composition
TestInteractor#test_interactor_can_be_rolled_back_when_composed
TestInteractor#test_context_knows_which_interactor_has_failed
TestInteractor#test_outcome_will_be_a_failure_when_an_error_occurred
TestInteractor#test_that_it_has_a_version_number
TestInteractor#test_interactor_can_be_rolled_back
TestInteractor#test_an_interactor_returns_a_result
TestInteractor#test_outcome_will_be_a_success_when_no_error_occurred
TestInteractor#test_it_is_possible_to_compose_interactors_in_reversed_order
TestInteractor#test_main_module_is_defined
TestInteractor#test_with_proc_is_possible_to_simulate_an_around_hook
TestInteractor#test_it_is_possible_to_use_a_struct_as_context
TestInteractor#test_it_is_possible_to_compose_interactors
TestInteractor#test_it_is_possibile_to_compose_interactor_with_sub_compositions
TestInteractor#test_when_using_struct_context_you_must_declare_all_members_in_advance
TestInteractor#test_it_is_possible_to_call_it_with_an_existent_context
TestInteractor#test_callable_method_could_be_customized
TestInteractor#test_when_doing_a_single_interactor_call_kwargs_could_be_used_to_initialize_context
TestInteractor#test_manual_validation
TestInteractor#test_with_proc_is_possible_to_simulate_an_around_hook_also_in_composition
TestInteractor#test_context_is_mutated_by_the_interactor
TestInteractor#test_when_using_composition_kwargs_could_be_used_to_initialize_context
TestDryValidationContract#test_validation_fails_the_context
TestDryValidationContract#test_validation_in_composition
TestDryValidationContract#test_railway_contract_validation
TestDryValidationContract#test_respond_to_validate
TestDryValidationContract#test_validates_only_declared_attributes
TestDryValidationContract#test_validation
TestDryValidationContract#test_railway_contract_validation_when_result_is_a_struct
TestDryValidationContract#test_type_validation
TestDryValidationContract#test_validation_in_composition_should_trigger_rollback_for_previous_interactors
TestDryValidationContract#test_validation_works_when_context_is_a_struct
TestDryValidationContract#test_railway_validation_adds_owner_to_failure_monad_when_it_fails
```

In `test/shy/test_helper.rb` a lot of interactor classes are defined to support
the test suites: they are decent examples to read.

Some interesting spotlights follows.

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
    schema do
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

Including `Shy::Interactor` module will make the descendant respond to `.>>` method
like a Proc object handling the _context_. Moreover any Proc (or Method) object
accepting a sole argument (the _context_) can be added in the composition chain.

> [!IMPORTANT]
> When using an arbitrary Proc, be sure to always return the context at the
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
> As you noticed in the last snippet custom proc objects are responsible to determine
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
