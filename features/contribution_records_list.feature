Feature: contribution records
In order to track contributions given to candidates
People should be able to
Create a list of contributions

Background: contribution records in the database

  Given the following contribution records exist:
  | election_year | cand_last | cand_first | cand_mid |cand_suf | party | district | office | contr_type | contr_date | contr_amount | contr_kind | contr_last | contr_first   | contr_mid | contr_suf | contr_mailing1   | contr_mailing2 | contr_city    | st | contr_zip  | contr_country |
  | 2012-09-13    | Agidius   | Cindy      |          |         | REP   | 5        | Rep A  |            | 5/16/2012  | 250.00       | Person     | Trail      | David/Suzanna |           |           | 1310 Youmans Ln  |                | Moscow        | ID | 83843      | USA           |
  | 2012-09-13    | Ahrens    | Danielle   |Rene      |         | REP   | 1        | Sen    |            | 2/17/2012  | 250.00       | Person     | Cowell     | Christina     |           |           | PO Box 25        |                | Bonners Ferry | ID | 83805      | USA           |
  | 2012-09-13    | Allred    | Keith      |          |         | DEM   | NULL     | Undec  |            | 6/5/2012   | 100.00       | Person     | Allred     | Keith         | C         |           | 2480 Edgewood Rd |                | Eagle         | ID | 83616-3928 | USA           |
  | 2012-09-13    | Ames      | Jeff       |          |         | REP   | 4        | Rep A  |            | 3/15/2012  | 100.00       | Person     | Ellison    | Courtenay     |           |           | 801 S River Hts  |                | Post Falls    | ID | 83854      | USA           |
  | 2012-09-13    | Ames      | Jeff       |          |         | REP   | 4        | Rep A  |            | 5/20/2012  | -100.00      | Person     | Ellison    | Courtenay     |           |           | 801 S River Hts  |                | Post Falls    | ID | 83854      | USA           |
  | 2012-09-13    | Andersen  | Terry      |          |         | REP   | 30       | Sen    | Loan       | 1/1/2010   | "2,187.04"   | Person     | Andersen   | Terry         |           |           | 809 S 4th #5     |                | Pocatello     | ID | 83201      | USA           |


Scenario: List Candidates
  When I go to the candidates page 
  Then I should see Candidate "Andersen"

Scenario: Show Candidate's Total Contributions
  When I go to the candidates page 
  Then I should see "2187.04"

Scenario: List Contributions
  When I go to the contributions page 
  Then I should see Candidate "Allred"

Scenario: List Contributors
  When I go to the contributors page 
  Then I should see "Ellison"

Scenario: Show Contributor's Total Contributions
  When I go to the contributors page 
  Then I should see "2187.04"


