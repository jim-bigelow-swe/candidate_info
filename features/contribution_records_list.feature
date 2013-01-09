Feature: contribution records
In order to track contributions given to candidates
People should be able to
Create a list of contributions

Background: contribution records in the database

  Given the following contribution records exist:
  | election_year | cand_last | cand_suf | cand_first | cand_mid | party | district | office                   | contr_date | contr_amount | contr_type | contr_last | contr_suf | contr_first | contr_mid | contr_mailing | contr_city | contr_st | contr_zip |
  | 2011-11-06    | Anderson  |          | Eric       |          | REP   | 1        | "STATE REP., POSITION A" | 2010-09-17 | 250.00       | C          | AGRA PAC   |           |             |           | PO BOX 4848   | POCATELLO  | ID       | 83205     | 
  | 2011-11-06    | Eskridge  |          | George     | E.       | REP   | 1        | "STATE REP., POSITION B" | 2010-08-28 | 250.00       | C          | AGRA PAC   |           |             |           | PO BOX 4848   | POCATELLO  | ID       | 83205     | 
  | 2011-11-06    | Keough    |          | Shawn      | A.       | REP   | 1        | STATE SENATOR            | 2010-08-09 | 250.00       | C          | AGRA PAC   |           |             |           | PO BOX 4848   | POCATELLO  | ID       | 83205     | 
  | 2011-11-06    | Keough    |          | Shawn      | A.       | REP   | 1        | STATE SENATOR            | 2010-04-20 | "1,000.00"   | C          | AGRICULTURE & NATURAL RESOURCES INDUSTRY PAC |  |  |  | 5685 PARAPET CT | BOISE | ID     | 83703     | 

Scenario: List Candidates
  When I go to the candidates page 
  Then I should see Candidate "Keough"

Scenario: Show Candidate's Total Contributions
  When I go to the candidates page 
  Then I should see "1250"

Scenario: List Contributions
  When I go to the contributions page 
  Then I should see Candidate "Keough"

Scenario: List Contributors
  When I go to the contributors page 
  Then I should see "AGRA PAC"

Scenario: Show Contributor's Total Contributions
  When I go to the contributors page 
  Then I should see "1000"


