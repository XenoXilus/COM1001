Feature: Tracking orders as an admin
  Scenario: Accessing the page as a customer and viewing the table
    Given I am logged in as "customer"
    When I go to customer orders
    Then I should see "Order Id"
    Then I should see "Text"
    Then I should see "Cost"
    Then I should see "Status"
    Then I should see "Select to cancel"

  Scenario: Cancelling an order
    Given I am logged in as "customer"
    When I go to customer orders
    When I check "status1"
    And I press "Cancel Orders!"
    Then I should see "Canceled" in row "1"

  Scenario: Cancelling multiple orders
    Given I am logged in as "customer"
    When I go to customer orders
    When I check "status2"
    When I check "status3"
    When I check "status4"
    And I press "Cancel Orders!"
    Then I should see "Canceled" in row "2"
    Then I should see "Canceled" in row "3"
    Then I should see "Canceled" in row "4"