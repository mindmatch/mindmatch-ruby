# MindMatch [![Build Status](https://travis-ci.org/mindmatch/mindmatch-ruby.svg?branch=master)](https://travis-ci.org/mindmatch/mindmatch-ruby)

MindMatch api client library for Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mindmatch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mindmatch

## Usage

```ruby
require 'mindmatch'

mindmatch = MindMatch.new(token: ENV['MINDMATCH_TOKEN'])
match_id = mindmatch.create_match(
  talents: [{"id" => 2, "name" => "John Snow", "email" => "js@winterfeld.uk",
    "profileUrls" => ["https://linkedin.com/in/johnsnow"], "skills" => ["Javascript", "ruby"]}
  ],
  position: {"mame" => "FE Developer", "description" => "Building a Ember aplication on a rails backend"}
)
#=> '6906ec3d-024d-43c6-a1cf-9b102eec4fb1'
mindmatch.query_match(id: match_id)
#=> {"id"=>"53b03dc2-07dd-40a2-91fe-7bff24c86574",
     "status"=>"fulfilled",
     "data"=>
     {"results"=>
       [{"score"=>0.1436655436,
         "personId"=>"7dedffb3-c41e-4046-aa3d-73979d7ec1c2",
         "positionId"=>"6214ab8d26e3f79571d922ca269d5743"}],
      "people"=>[{"id"=>"7dedffb3-c41e-4046-aa3d-73979d7ec1c2", "refId"=>"2"}],
      "positions"=>[{"id"=>"6214ab8d26e3f79571d922ca269d5743", "refId"=>"324"}]}}
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mindmatch/mindmatch-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mindmatch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mindmatch/mindmatch-ruby/blob/master/CODE_OF_CONDUCT.md).
