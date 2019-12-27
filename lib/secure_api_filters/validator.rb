# frozen_string_literal: true

require 'secure_api_filters/error'
require 'secure_api_filters/definitions'
require 'active_record'

module SecureApiFilters
  class Validator
    class << self
      def validate_custom_scope(scope_type, value)
        raise SecureApiFilters::InvalidValueError, value unless
        Definitions.public_send(scope_type.to_sym, value)
      end

      def validate_scope_type(scope_type)
        raise ArgumentError, "#{scope_type} is not a valid scope type" unless
        ['bigint', :bigint,
         'boolean', :boolean,
         'decimal', :decimal,
         'integer', :integer,
         'float', :float,
         'string', :string,
         'text', :text].include?(scope_type) || Definitions.respond_to?(scope_type.to_sym)
      end

      def validate_type_of_value(scope_type, value)
        case scope_type
        when 'string', :string, 'text', :text
          true
        when 'boolean', :boolean
          raise SecureApiFilters::InvalidValueError, value unless
          value.boolean_value?
        when 'bigint', :bigint, 'integer', :integer
          raise SecureApiFilters::InvalidValueError, value unless
          value.integer_value?
        when 'decimal', :decimal, 'float', :float
          raise SecureApiFilters::InvalidValueError, value unless
          value.decimal_or_float_value?
        else
          validate_custom_scope(scope_type, value)
        end
      end
    end
  end
end
