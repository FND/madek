Feature: Inheritance of contexts

  As a MAdeK user
  I want add individual data to media entries
  So that I store my specialized meta data

  @jsbrowser 
  Scenario: Inherit contexts from another set
    Given I am signed-in as "Adam"
    When I put a set A that has media entries in set B that has any context
    And I click on "Vokabular"
    Then all the contexts of the set B are listed for set A
    And Set A bequests all contexts to every media entry of its children

  @firefox
  Scenario: Remove contexts from a set while disconnecting from inheriting set
    Given I am signed-in as "Adam"
    When I remove a set A from a set B from which set A is inheriting a context
    Then this context is removed from set A
    And all media entries contained in set A doesnt have that context anymore

  @firefox
  Scenario: Disconnect contexts from a set
    Given I am signed-in as "Adam"
    When I edit the contexts of a set that has contexts
    And I disconnect any contexts from that set
    And I confirm the browser dialog
    And I wait until there are no more ajax requests running
    Then those contexts are no longer connected to that set
    And all media entries contained in that set do not have the disconnected contexts any more
