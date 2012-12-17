Feature: Making top level sets visible

  In order be able to focus on top level sets first (sets without parents)
  As a user
  I want to see top parents with a higher priority

  @javascript
  Scenario: Viewing my sets
    Given I am "Normin"
     When I visit my sets
     Then I see all my sets

  @javascript
  Scenario: Switch between all my sets and all my top level sets
    Given I am "Normin"
      And I am on my sets page
      And I follow "Alle meine Sets"
     Then I see all my sets
     When I switch the scope to all my top level sets
     Then I only see my top level sets
