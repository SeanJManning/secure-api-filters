# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :students, force: true do |t|
    t.string :first_name
    t.string :last_name
    t.bigint :student_id
    t.integer :age
    t.decimal :weighted_gpa
    t.float :gpa
    t.boolean :honor_roll
    t.datetime :graduation_date
    t.integer :university_id
    t.timestamps
  end

  create_table :users, force: true do |t|
    t.boolean :admin
    t.timestamps
  end

  create_table :universities, force: true do |t|
    t.string :mascot
  end
end
