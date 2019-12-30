# frozen_string_literal: true

require 'secure_api_filters'
require 'spec_helper'

describe SecureApiFilters do
  describe 'filtering active record models' do
    let(:admin) { User.create(admin: true) }
    let(:user) { User.create(admin: false) }
    let(:student1) do
      Student.create(first_name: 'John', last_name: 'Doe', age: 18,
                     gpa: 4.0, weighted_gpa: 4.26522643,
                     student_id: 24_672_467_426, honor_roll: true)
    end
    let(:student2) do
      Student.create(first_name: 'Jane', last_name: 'Doe', age: 17,
                     gpa: 2.0, weighted_gpa: 2.45992473,
                     student_id: 82_737_272_737, honor_roll: false)
    end

    describe '.filters' do
      it 'raises an ArgumentError if an argument is not a attribute' do
        expect { Student.filters(:undefined_attribute) }.to raise_error(ArgumentError)
      end

      it 'does not raise an error if the arguments are all attributes' do
        expect { Student.filters(:first_name, :last_name, :age, :gpa, :honor_roll) }.not_to raise_error
      end

      it 'creates a class method for each filter to be called later' do
        %i[first_name last_name age gpa honor_roll].each do |filter|
          expect(Student.respond_to?(:"custom_filter_#{filter}")).to eq(true)
        end
      end

      context 'scope type is string or text' do
        it 'is case insensitive' do
          expect(Student._filter(first_name: 'john')).to eq([student1])
        end
        it { expect(Student._filter(first_name: 'John')).to eq([student1]) }
      end

      context 'scope type is bigint' do
        it { expect(Student._filter(student_id: '24672467426')).to eq([student1]) }
        it { expect(Student._filter(student_id: '82737272737')).to eq([student2]) }
      end

      context 'scope type integer' do
        it { expect(Student._filter(age: '18')).to eq([student1]) }
        it { expect(Student._filter(age: '17')).to eq([student2]) }
      end

      context 'scope type decimal' do
        it { expect(Student._filter(weighted_gpa: '4.26522643')).to eq([student1]) }
        it { expect(Student._filter(weighted_gpa: '2.45992473')).to eq([student2]) }
      end

      context 'scope type float' do
        it { expect(Student._filter(gpa: '4.0')).to eq([student1]) }
        it { expect(Student._filter(gpa: '2.0')).to eq([student2]) }
      end

      context 'scope type is boolean' do
        it { expect(Student._filter(honor_roll: 'true')).to eq([student1]) }
        it { expect(Student._filter(honor_roll: 'false')).to eq([student2]) }
      end
    end

    describe '._filter' do
      it 'returns an ActiveRecord::Relation' do
        expect(Student._filter).to eq([student1, student2])
        expect(Student.where(first_name: 'John')._filter).to eq([student1])
        expect(Student.where(first_name: 'Jane')._filter).to eq([student2])
      end

      it 'raises an error if filters is not a hash or nil' do
        expect(Student._filter(nil)).to eq([student1, student2])
        expect(Student._filter({})).to eq([student1, student2])
        expect { Student._filter([{ first_name: 'john' }]) }.to raise_error(ArgumentError, 'The filters argument must be a hash or nil')
        expect { Student._filter('john') }.to raise_error(ArgumentError, 'The filters argument must be a hash or nil')
      end

      it 'does not require a second argument' do
        expect(Student._filter(first_name: 'John')).to eq([student1])
        expect(Student._filter(first_name: 'Jane')).to eq([student2])
      end

      it 'raises BlankValueError if filter value is blank' do
        expect { Student._filter(first_name: '') }.to raise_error(SecureApiFilters::BlankValueError)
      end

      it 'handles single filters correctly' do
        expect(Student._filter({ at_risk: 'false' }, current_user: admin)).to eq([student1])
        expect(Student._filter({ at_risk: 'true' }, current_user: admin)).to eq([student2])
      end

      it 'handles multiple filters correctly' do
        expect(Student._filter({ at_risk: 'false', first_name: 'John' }, current_user: admin)).to eq([student1])
        expect(Student._filter({ at_risk: 'true', first_name: 'Jane' }, current_user: admin)).to eq([student2])
        expect { Student._filter({ at_risk: 'true', first_name: 'Jane' }, current_user: user) }.to raise_error(SecureApiFilters::ForbiddenFilterError)
      end

      it 'does not mutate the previous active record relation' do
        expect(Student.where(first_name: 'John')._filter({ at_risk: 'false', first_name: 'John' }, current_user: admin)).to eq([student1])
        expect(Student.where(first_name: 'Jane')._filter({ at_risk: 'true', first_name: 'Jane' }, current_user: admin)).to eq([student2])
        expect(Student.where(first_name: 'Foo')._filter({ at_risk: 'false', first_name: 'John' }, current_user: admin)).to eq([])
        expect(Student.where(first_name: 'Foo')._filter({ at_risk: 'true', first_name: 'Jane' }, current_user: admin)).to eq([])
        expect(Student.where('1=0')._filter({ at_risk: 'false', first_name: 'John' }, current_user: admin)).to eq([])
        expect(Student.where('1=0')._filter({ at_risk: 'true', first_name: 'Jane' }, current_user: admin)).to eq([])
      end

      it 'raises InvalidFilterError if the filter does not exist' do
        expect { Student._filter({ state: 'Fl' }, current_user: user) }.to raise_error(SecureApiFilters::InvalidFilterError)
      end
    end

    describe '.custom_filter' do
      context 'using a joins to filter a relationship' do
        let(:university1) { University.create(mascot: 'tiger') }
        let(:university2) { University.create(mascot: 'elephant') }

        before(:each) do
          student1.update(university_id: university1.id)
          student2.update(university_id: university2.id)
        end

        it { expect(Student._filter(university_mascot: 'Tiger')).to eq([student1]) }
        it { expect(Student._filter(university_mascot: 'Elephant')).to eq([student2]) }
      end

      it 'uses string as a default scope_type if none is given' do
        expect(Student._filter(fname: 'john')).to eq([student1])
        expect(Student._filter(fname: 'jane')).to eq([student2])
      end

      it 'can use a custom defintion to validate the value' do
        expect { Student._filter(lname: 'foo') }.to raise_error(SecureApiFilters::InvalidValueError)
        expect(Student._filter(lname: 'Doe')).to eq([student1, student2])
      end

      context 'scope type float' do
        it { expect(Student._filter({ at_risk: 'false' }, current_user: admin)).to eq([student1]) }
        it { expect(Student._filter({ at_risk: 'true' }, current_user: admin)).to eq([student2]) }
      end

      context 'scope type string' do
        it { expect(Student._filter(fname: 'John')).to eq([student1]) }
        it { expect(Student._filter(fname: 'Jane')).to eq([student2]) }
        it { expect(Student._filter(lname: 'Doe')).to eq([student1, student2]) }
      end
    end
  end
end
