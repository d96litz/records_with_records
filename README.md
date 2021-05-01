# RecordsWithRecords

**Please consider that this gem is currently in a beta state**

This gem aims to simplify exists queries

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'records_with_records'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install records_with_records

## Usage
Assume you have a relation like this
```ruby
class User < ActiveRecord::Base
  has_many :received_messages, class_name: 'Message', foreign_key: :receiver_id
end
```
### Exists
To get all Users with associated Messages you would write
```ruby
User.where(Message.where('receiver_id = users.id').arel.exists)
=> SELECT "users".* FROM "users" WHERE EXISTS (SELECT "messages".* FROM "messages" WHERE (receiver_id = users.id))
```
Instead you can now write
```ruby
User.where_exists(:received_messages)
=> SELECT "users".* FROM "users" WHERE EXISTS (SELECT "messages".* FROM "messages" WHERE ("messages"."receiver_id" = "users"."id"))
```
### Not exists
Querying records without associated records is also possible
```ruby
User.where_not_exists(:received_messages)
=> SELECT "users".* FROM "users" WHERE NOT (EXISTS (SELECT "messages".* FROM "messages" WHERE ("messages"."receiver_id" = "users"."id")))
```

### Additional scope
You can pass a scope as second argument
```ruby
User.where_not_exists(:received_messages, -> { where(received_at: 5.hours.ago..) })
=> SELECT "users".* FROM "users" WHERE NOT (EXISTS (SELECT "messages".* FROM "messages" WHERE "messages"."received_at" >= $1 AND ("messages"."receiver_id" = "users"."id"))) [["received_at", "2021-05-01 04:16:42.325804"]]
```

### Association scope
Scopes defined on the association are also applied
```ruby
class User < ActiveRecord::Base
  has_many :pending_messages, -> { where(messages: {received_at: nil}) }, class_name: 'Message', foreign_key: :receiver_id
end

User.where_exists(:pending_messages)
=> SELECT "users".* FROM "users" WHERE EXISTS (SELECT "messages".* FROM "messages" WHERE "messages"."received_at" IS NULL AND ("messages"."receiver_id" = "users"."id"))
```

## Caveats
Querying on the existance of `belongs_to` associations is currently not possible.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/records_with_records. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/records_with_records/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RecordsWithRecords project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/records_with_records/blob/master/CODE_OF_CONDUCT.md).
