Feature: Setting loyalty offers as admin and receiving rewards customer

  Scenario: Successfully setting offer parameters
    Given I am logged in as "admin"
    When I go to offers
    When I fill in "norders" with "1"
    When I fill in "cp" with "10"
    And I press "Update"
    Given the customer's "address" is "adr"
    Given the customer's "balance" is "100"
    When a customer tweets "@curryhouse02 order 9"
    And I go to orders
    When I go to search customer Alexg7g7
    Then I should see "108.9"
    Then delete customer order