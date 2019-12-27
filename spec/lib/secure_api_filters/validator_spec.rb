# frozen_string_literal: true

describe 'SecureApiFilters::SecureApiFilters::Validator' do
  describe 'seperation of concerns' do
    it 'the model shouldn\'t have access to the Validator class methods' do
      expect { Student.validate_scope_type(:new) }.to raise_error(NoMethodError)
    end
  end
  describe '.validate_scope_type' do
    context 'when the scope type is standard' do
      [:boolean, 'boolean', :bigint, 'bigint', :integer, :integer, 'decimal', :decimal, 'float',
       :float, 'string', :string, 'text', :text].each do |scope_type|
         it { expect { SecureApiFilters::Validator.validate_scope_type(scope_type).not_to raise_error(ArgumentError) } }
       end
    end

    context 'when the scope type is not defined' do
      it { expect { SecureApiFilters::Validator.validate_scope_type(:undefined) }.to raise_error(ArgumentError) }
      it { expect { SecureApiFilters::Validator.validate_scope_type('undefined') }.to raise_error(ArgumentError) }
    end

    context 'when the scope type is defined' do
      it { expect { SecureApiFilters::Validator.validate_scope_type(:custom_definition) }.not_to raise_error }
      it { expect { SecureApiFilters::Validator.validate_scope_type('custom_definition') }.not_to raise_error }
    end
  end

  describe '.validate_custom_scope' do
    it { expect { SecureApiFilters::Validator.validate_custom_scope('custom_definition', 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
    it { expect { SecureApiFilters::Validator.validate_custom_scope(:custom_definition, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
    it { expect { SecureApiFilters::Validator.validate_custom_scope('custom_definition', 'bar') }.not_to raise_error }
    it { expect { SecureApiFilters::Validator.validate_custom_scope(:custom_definition, 'bar') }.not_to raise_error }
  end

  describe '.validate_type_of_value' do
    context 'when scope_type is a string or text' do
      ['string', :string, 'text', :text].each do |scope_type|
        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.not_to raise_error }
      end
    end

    context 'when scope_type is a bigint' do
      ['bigint', :bigint].each do |scope_type|
        %w[-1234567890 1234567890].each do |value|
          it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, value) }.not_to raise_error }
        end

        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, '1.0') }.to raise_error(SecureApiFilters::InvalidValueError) }
        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
      end
    end

    context 'when scope_type is an integer' do
      ['integer', :integer].each do |scope_type|
        %w[-1 1 10 -10 100].each do |value|
          it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, value) }.not_to raise_error }
        end

        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, '1.0') }.to raise_error(SecureApiFilters::InvalidValueError) }
        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
      end
    end

    context 'when scope_type is a float' do
      ['float', :float].each do |scope_type|
        %w[-1.0 .1 1.0 -.1 1.01 10.1].each do |value|
          it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, value) }.not_to raise_error }
        end

        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, '1.') }.to raise_error(SecureApiFilters::InvalidValueError) }
        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
      end
    end

    context 'when scope_type is a decimal' do
      ['decimal', :decimal].each do |scope_type|
        %w[-1.1234567890 .1234567890 1.1234567890 -.1234567890 10.1234567890 100.1234567890].each do |value|
          it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, value) }.not_to raise_error }
        end

        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, '1.') }.to raise_error(SecureApiFilters::InvalidValueError) }
        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
      end
    end

    context 'when scope_type is a boolean' do
      ['boolean', :boolean].each do |scope_type|
        %w[0 1 true false].each do |value|
          it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, value) }.not_to raise_error }
        end

        it { expect { SecureApiFilters::Validator.validate_type_of_value(scope_type, 'foo') }.to raise_error(SecureApiFilters::InvalidValueError) }
      end
    end
  end
end
