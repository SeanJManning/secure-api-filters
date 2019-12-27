# frozen_string_literal: true

module SecureApiFilters
  class Error < StandardError
    attr_reader :name
    def initialize(name)
      super
      @name = name
    end
  end
  class BlankValueError < StandardError; end
  class InvalidValueError < Error; end
  class InvalidFilterError < Error; end
  class ForbiddenFilterError < Error; end
end
