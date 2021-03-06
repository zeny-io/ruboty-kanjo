# Ruboty::Kanjo

Provides get pricing operations for ruboty.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-kanjo'
```

And then execute:

    $ bundle

## Usage

```
ruboty /kanjo aws billing\z/ - fetch aws billing
ruboty /kanjo aws spot (?<availability_zone>[a-z0-9-]+) (?<instances>[a-z0-9.]+(?:\s*,\s*[a-z0-9.]+)*)\z/ - fetch aws spot instacne prices
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zeny-io/ruboty-kanjo.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

