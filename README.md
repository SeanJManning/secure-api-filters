# Secure Api Filters

Have you ever submitted a filter query to a web application or API backend and received a result, only to later realize that it wasn't actually filtering as you had anticipated? This gem helps you to avoid that scenario with type casted filters for your `ActiveRecord` models in Rails and Sinatra.

![Travis Build status](https://travis-ci.org/SeanJManning/secure-api-filters.svg?branch=master)

## Usage

The `SecureApiFilters` module provides three simple class methods: `_filter`, `filters` and `custom_filter` for your `ActiveRecord` models.

```ruby

# == Schema Information
#
# Table name: students
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  student_id      :bigint
#  age             :integer
#  weighted_gpa    :decimal(, )
#  gpa             :float
#  honor_roll      :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Student < ActiveRecord::Base
  include SecureApiFilters
end
```

### The `_filter` method

`def _filter(filters = {}, context = nil)`

The `_filter` method, when run successfully, will always return an `ActiveRecord::Relation`. The first argument is a hash of key value pairs `{ first_name: 'foo', last_name: 'bar', at_risk: true }` and the second argument is a context object `{ current_user: current_user, browser_time_zone: browser_time_zone }` that will be available to the `custom_filter` method.

```ruby
class StudentsController < ApplicationController
  def index
    context = {}
    context[:current_user] = current_user
    context[:browser_time_zone] = browser_time_zone
    render json: Student._filter(params[:filter], context)
  end
end
```
Note: `filter` is now a reserved name in Rails.

### The `filters` method

The `filters` method accepts a list of attributes that your `ActiveRecord` model can be filtered on, which will become available as the keys for the filter params hash in your query string. Attributes may only have the following data types: `string, text, bigint, integer, float, decimal, boolean`. Other data types should use the `custom_filter` method.

```ruby
class Student < ActiveRecord::Base
  include SecureApiFilters

  filters :id, :first_name, :last_name, :student_id, :age, :weighted_gpa, :gpa, :honor_roll
end
```
These attribute filters are used to create basic `where clause` queries. By default, filters with a data type of `string` and `text` are case insensitive.

#### Examples

If a user was attempting to access `http://example.com/students?filter[last_name]=Foo&filter[age]=18` this would result in the following query

```sql
  SELECT "users".* FROM users WHERE (lower(last_name)='foo') AND age='18'
```

#### Type casting

The values passed into the filters hash will be checked based on the data type of the column. If you disagree with the predefined type definitions, you may create your own definition to be used with the `custom_filter` method.

#### Naming

If you don't wish to use the name of your column as the filter key, you can instead use the `custom_filter` method.

```ruby
custom_filter :fname, ->(value, _context) {
  where(first_name: value)
}
```

### The `custom_filter` method

`custom_filter` has a default type of `string`. The available type options are `:string, :text, :bigint, :integer, :float, :decimal, :boolean`. It receives the optional `context` argument from the `_filter` method which can be used to help scope the records returned.

#### Examples

```ruby
class Student < ActiveRecord::Base
  include SecureApiFilters

  custom_filter :search, ->(value, context) {

    raise SecureApiFilters::ForbiddenFilter, :search unless
    options[:current_user] && (options[:current_user].admin? || options[:current_user].paid_account?)

    where('lower(first_name) = ? OR lower(last_name) = ? OR lower(email) = ?', value.downcase, value.downcase, value.downcase)
  }

  custom_filter :at_risk, :boolean, ->(value, _context) {
    value ? where('gpa < ?', 2.5) : where('gpa >= ?', 2.5)
  }
end
```

#### Custom type definitions

If you do not agree with the predefined type definitions for `:string, :text, :bigint, :integer, :float, :decimal, :boolean` you may add your own global definitions as class methods into the `SecureApiFilters::Definitions` module. Your class method should receive a single argument and return either `true` or `false`. `SecureApiFilters::InvalidValueError` will be raised if `false` is returned.

```ruby
module SecureApiFilters
  module Definitions
    def self.month(value)
      (1..12).include?(value.to_i)
    end
  end
end

class Student
  include SecureApiFilters

  custom_filter :graduation_month, :month, ->(value, context) { # code };
end
```

#### Value conversion

After the value passed into `custom_filter` is validated to be of the specified data type, it is converted from a string to that data type _before_ it is called in the proceeding block. Custom defined data types will always remain a string.

```ruby
class Student
  include SecureApiFilters

  custom_filter :graduation_month, :custom_defined_datatype, ->(value, context) {
    # value will always be passed into the block as a String object
  };

  custom_filter :gpas_more_than, :float, ->(value, context) {
    # value will be passed into the block as a Float object
  }
end
```

#### Filtering on Relationships

```ruby
class Student
  belongs_to :university
  include SecureApiFilters

  custom_filter :university_mascot, :string, ->(value, _context) {
    joins(:university).where('lower(universities.mascot) = ?', value.downcase)
  };
end
```

#### Using `custom_filter` in other areas of your application

The `custom_filter`class method generates a unique class method, `custom_filter_{scope_name}` which could be used as a scope in other areas of your application:

```ruby
Student.custom_filter_at_risk('true')
```

### Custom Errors

The `SecureApiFilter` module throws four unique errors:
* `BlankValueError`
* `InvalidFilterError`
* `InvalidValueError`
* `ForbiddenFilterError`

It is up to you to rescue these errors and provide a response to the client.

## Coming Soon

- Sorts and Custom Sorts
- Make attribute filters of `has_one` and `belongs_to` relationships available in the filters method.

For example:
```ruby
class Student
  belongs_to :university
  include SecureApiFilters

  filters :university_mascot
end
```

## Installation

### Rails

1.  Add to your gemfile:

```ruby
gem 'secure_api_filters'
```

2.  Execute:

```sh
$ bundle install
```
### Sinatra

1. Add to your gemfile

```ruby
gem 'sinatra/activerecord'
gem 'secure_api_filters'
```

2.  Execute:

```sh
$ bundle install
```

## Running Tests

RSpec is used for testing.

```sh
$ bundle exec rspec
```

## Contributing

<a href="https://rubystyle.guide/">Ruby Style Guide</a> :smiley:

## License

The gem is available as open source under the terms of the <a href="http://opensource.org/licenses/MIT">MIT License</a>.
