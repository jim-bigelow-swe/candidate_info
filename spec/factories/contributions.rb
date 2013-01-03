# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contribution do
    candidate_id nil
    contributor_id nil
    date "2013-01-02"
    amount "9.99"
    contribution_type "MyString"
  end
end
