# frozen_string_literal: true

require 'spec_helper'
require 'secure_api_filters/version.rb'

describe 'SecureApiFilters::Version' do
  describe '.gem_version' do
    it 'provides valid semantic versioning' do
      expect(SecureApiFilters.gem_version.to_s).to match(/\d+\.\d+\.\d+/)
    end
  end
end
