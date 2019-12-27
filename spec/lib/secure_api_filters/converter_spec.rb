# frozen_string_literal: true

describe 'SecureApiFilters::SecureApiFilters::Definitions' do
  describe 'seperation of concerns' do
    it 'the model shouldn\'t have access to the Definitions class methods' do
      expect { Student.convert_value('string', 'foo') }.to raise_error(NoMethodError)
    end
  end

  describe '.convert_value' do
    context 'when scope type is string, text or custom' do
      [:string, 'string', :text, 'text', :custom, 'custom'].each do |scope_type|
        %w[0 1.0 false foo1].each do |val|
          it { expect(SecureApiFilters::Converter.convert_value(scope_type, val)).to eql(val) }
        end
      end
    end

    context 'when the scope type is boolean' do
      [:boolean, 'boolean'].each do |scope_type|
        %w[0 true].each do |val|
          it { expect(SecureApiFilters::Converter.convert_value(scope_type, val)).to eql(true) }
        end
        %w[1 false].each do |val|
          it { expect(SecureApiFilters::Converter.convert_value(scope_type, val)).to eql(false) }
        end
      end
    end

    context 'when the scope type is integer' do
      it { expect(SecureApiFilters::Converter.convert_value(:integer, '5')).to eql(5) }
      it { expect(SecureApiFilters::Converter.convert_value('integer', '5')).to eql(5) }

      context 'when the value is a negative number' do
        it { expect(SecureApiFilters::Converter.convert_value(:integer, '-8')).to eql(-8) }
        it { expect(SecureApiFilters::Converter.convert_value('integer', '-8')).to eql(-8) }
      end
    end

    context 'when the scope type is bigint' do
      it { expect(SecureApiFilters::Converter.convert_value(:bigint, '5')).to eql(5) }
      it { expect(SecureApiFilters::Converter.convert_value('bigint', '5')).to eql(5) }

      context 'when the value is a negative number' do
        it { expect(SecureApiFilters::Converter.convert_value(:bigint, '-8')).to eql(-8) }
        it { expect(SecureApiFilters::Converter.convert_value('bigint', '-8')).to eql(-8) }
      end
    end

    context 'when the scope type is float' do
      it { expect(SecureApiFilters::Converter.convert_value(:float, '4.5')).to eql(4.5) }
      it { expect(SecureApiFilters::Converter.convert_value('float', '4.5')).to eql(4.5) }
      it { expect(SecureApiFilters::Converter.convert_value(:float, '.5')).to eql(0.5) }
      it { expect(SecureApiFilters::Converter.convert_value('float', '.5')).to eql(0.5) }

      context 'when the value is a negative number' do
        it { expect(SecureApiFilters::Converter.convert_value(:float, '-5.0')).to eql(-5.0) }
        it { expect(SecureApiFilters::Converter.convert_value('float', '-5.0')).to eql(-5.0) }
        it { expect(SecureApiFilters::Converter.convert_value(:float, '-.5')).to eql(-0.5) }
        it { expect(SecureApiFilters::Converter.convert_value('float', '-.5')).to eql(-0.5) }
      end
    end

    context 'when the scope type is decimal' do
      it { expect(SecureApiFilters::Converter.convert_value(:decimal, '4.5')).to eql(4.5) }
      it { expect(SecureApiFilters::Converter.convert_value('decimal', '4.5')).to eql(4.5) }
      it { expect(SecureApiFilters::Converter.convert_value(:decimal, '.5')).to eql(0.5) }
      it { expect(SecureApiFilters::Converter.convert_value('decimal', '.5')).to eql(0.5) }

      context 'when the value is a negative number' do
        it { expect(SecureApiFilters::Converter.convert_value(:decimal, '-5.0')).to eql(-5.0) }
        it { expect(SecureApiFilters::Converter.convert_value('decimal', '-5.0')).to eql(-5.0) }
        it { expect(SecureApiFilters::Converter.convert_value(:decimal, '-.5')).to eql(-0.5) }
        it { expect(SecureApiFilters::Converter.convert_value('decimal', '-.5')).to eql(-0.5) }
      end
    end
  end
end
