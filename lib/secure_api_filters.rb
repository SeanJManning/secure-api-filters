# frozen_string_literal: true

require 'secure_api_filters/error'
require 'secure_api_filters/validator'
require 'secure_api_filters/core_ext'
require 'secure_api_filters/definitions'
require 'secure_api_filters/converter'

module SecureApiFilters
  extend ActiveSupport::Concern

  class_methods do
    def _filter(filters = {}, context = nil)
      if filters.nil? || (filters.is_a?(Hash) && filters.blank?)
        return where(nil)
      end

      raise ArgumentError, 'The filters argument must be a hash or nil' unless
      filters.is_a?(Hash)

      results = self
      filters.each do |key, value|
        raise BlankValueError unless value.present?

        begin
          results = results.public_send(:"custom_filter_#{key}", value, context)
        rescue NoMethodError
          raise InvalidFilterError, key
        end
      end
      results
    end

    def filters(*filters)
      @valid_attribute_filters ||=
        columns.select { |x| %i[bigint boolean decimal integer float string text].include?(x.type) }
               .map { |x| [x.name, x.type] }.to_h

      filters.each do |filter|
        unless @valid_attribute_filters.key?(filter.to_s)
          raise ArgumentError, "\"#{filter}\" is not a valid attribute " \
            'filter. It must have a datatype of bigint, boolean, decimal, integer, float, ' \
            'string or text. The custom_filter method may be helpful.'
        end
        define_singleton_method :"custom_filter_#{filter}" do |value, _context|
          type = @valid_attribute_filters[filter.to_s]
          Validator.validate_type_of_value(type, value)
          if %i[string text].include?(type)
            where("lower(#{filter}) = ?", value.downcase)
          else
            where(filter => value)
          end
        end
      end
    end

    def custom_filter(scope_name, scope_type = 'string', body, &block)
      Validator.validate_scope_type(scope_type)
      define_singleton_method :"custom_filter_#{scope_name}" do |value, context|
        Validator.validate_type_of_value(scope_type, value)
        scope(scope_name, body, &block)
        public_send(scope_name, Converter.convert_value(scope_type, value), context)
      end
    end
  end
end
