# Capistrano::Ninetyninetests

This gem integrates your project with 99tests CrowdCI.

Use this gem to automatically update bugfix status and launch new cycles to test your product.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ninetyninetests', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-ninetyninetests

## Usage

To trigger a new test cycle on 99tests, create a TESTME.md file with requirements before you deploy your code.

Add bug hastags(e.g. #bug-12543) to your commit messages to automatically mark bugs as fixed everytime you deploy the code.

New cycles will be triggered everytime you modify TESTME.md and deploy.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/capistrano-ninetyninetests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Capistrano::Ninetyninetests project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/capistrano-ninetyninetests/blob/master/CODE_OF_CONDUCT.md).
