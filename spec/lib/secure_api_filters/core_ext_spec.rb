# frozen_string_literal: true

require 'active_record'

describe 'String' do
  describe '.integer_value?' do
    %w[01 1 10 100 -1 -10 -100 -01].each do |str|
      it { expect(str.integer_value?).to eq(true) }
    end

    %w[1.5 -1.5 1. 100z z100].each do |str|
      it { expect(str.integer_value?).to eq(false) }
    end
  end

  describe '.boolean_value?' do
    %w[0 1 true false].each do |str|
      it { expect(str.boolean_value?).to eq(true) }
    end

    %w[-1 2 foo].each do |str|
      it { expect(str.boolean_value?).to eq(false) }
    end
  end

  describe '.decimal_or_float_value?' do
    %w[1.0 10.0 100.0 10.01 0.1 0.11 .11 -1.0 -10.0
       -100.0 -10.01 -0.1 -0.11 -.11].each do |str|
      it { expect(str.decimal_or_float_value?).to eq(true) }
    end

    %w[1 -1 10 -10 z1.0 1.05z 1z.5].each do |str|
      it { expect(str.decimal_or_float_value?).to eq(false) }
    end
  end
end
