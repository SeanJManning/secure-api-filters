# frozen_string_literal: true

class String
  def boolean_value?
    !!%w[true false 0 1].include?(self)
  end

  def integer_value?
    !!(self =~ /\A[-]?\d+\z/)
  end

  def decimal_or_float_value?
    !!(self =~ /\A[-]?\d*\.{1}\d+\z/)
  end
end
