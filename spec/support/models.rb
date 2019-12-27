# frozen_string_literal: true

module SecureApiFilters
  module Definitions
    def self.custom_definition(value)
      value != 'foo'
    end
  end
end

class Student < ActiveRecord::Base
  include SecureApiFilters

  filters :first_name, :last_name, :student_id, :age, :weighted_gpa, :gpa, :honor_roll

  custom_filter :at_risk, :boolean, ->(value, context) {
    raise SecureApiFilters::ForbiddenFilterError, :at_risk unless
    context[:current_user] && context[:current_user].admin?

    value ? where('gpa < ?', 2.5) : where('gpa >= ?', 2.5)
  }

  custom_filter :fname, ->(value, _context) {
    where('first_name LIKE ?', value)
  }

  custom_filter :lname, :custom_definition, ->(value, _context) {
    where('last_name LIKE ?', value)
  }
end

class User < ActiveRecord::Base
end
