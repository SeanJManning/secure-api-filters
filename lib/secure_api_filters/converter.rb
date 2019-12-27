# frozen_string_literal: true

module SecureApiFilters
  module Converter
    def self.convert_value(scope_type, value)
      case scope_type
      when 'boolean', :boolean
        %w[0 true].include?(value) ? true : false
      when 'integer', :integer, 'bigint', :bigint
        value.to_i
      when 'float', :float
        value.to_f
      when 'decimal', :decimal
        value.to_d
      else
        # if scope_type is custom, string or text,
        # it will always recieve a string
        value
      end
    end
  end
end
