# frozen_string_literal: true

# order matters

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
load 'support/schema.rb'
require 'support/models.rb'
require 'database_cleaner'

RSpec.configure do |config|
  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end
