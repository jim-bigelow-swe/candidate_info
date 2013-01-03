# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :candidate do
    elected false
    year "2013-01-02"
    last "MyString"
    suffix "MyString"
    first "MyString"
    middle "MyString"
    party "MyString"
    district "MyString"
    office "MyString"
  end
end
