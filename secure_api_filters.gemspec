# frozen_string_literal: true

require './lib/secure_api_filters/version'

Gem::Specification.new do |s|
  s.name = 'secure_api_filters'
  s.version = SecureApiFilters.gem_version.to_s
  s.date = '2019-12-18'
  s.authors = ['Sean Manning']
  s.summary = 'Module providing custom type casted ' \
              'filtering of ActiveRecord models.'
  s.homepage = 'https://github.com/SeanJManning/secure-api-filters'
  s.files = ['lib/secure_api_filters.rb']
  s.require_paths = ['lib']
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.5'
  s.add_dependency 'activerecord', ENV['ACTIVE_RECORD_VERSION'] || '>= 5.2.3'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rspec', '>= 3.2'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
end
