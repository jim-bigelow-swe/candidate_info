# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contributor do
    last "MyString"
    suffix "MyString"
    first "MyString"
    middle "MyString"
    mailing "MyString"
    city "MyString"
    state "MyString"
    zip "MyString"
  end
end
