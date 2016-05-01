Feature: Tracking orders as an admin

  Scenario: Accessing the page as admin and viewing the table
    Given I am logged in as "admin"
    When I go to orders
    Then I should see "Order Id"
    Then I should see "Tweet Id"
    Then I should see "From"
    Then I should see "Text"
    Then I should see "Sum"
    Then I should see "Status"
    Then I should see "Select to change"

  Scenario: Displaying new orders and canceling
    Given I am logged in as "admin"
    When I go to orders
    When a customer orders "1 3 5"
    When I go to orders
    Then I should see "1 3 5"
    When a customer cancels "1 3 5"
    When I go to orders
    Then I should see "Canceled" within "order 1 3 5"

  Scenario: Changing an order status
    Given I am logged in as "admin"
    When I go to orders
    When I check "status1"
    When I select "Preparing" from "change_to"
    And I press "Change Status!"
    Then I should see "Preparing" in row "1"

  Scenario: Changing multiple order statuses
    Given I am logged in as "admin"
    When I go to orders
    When I check "status1"
    When I check "status2"
    When I check "status3"
    When I select "Delivering" from "change_to"
    And I press "Change Status!"
    Then I should see "Delivering" in row "1"
    Then I should see "Delivering" in row "2"
    Then I should see "Delivering" in row "3"

  Scenario: Viewing Sheffield-only orders
    Given I am logged in as "admin"
    When I go to orders
    When a "sheffield" customer orders "5 6 7"
    When I follow "Sheffield"
    Then I should see "5 6 7"
    When I follow "Birmingham"
    Then I should not see "5 6 7"
    When I follow "All"
    Then I should see "5 6 7"

  Scenario: Viewing Birmingham-only orders
    Given I am logged in as "admin"
    When I go to orders
    When a "birmingham" customer orders "7 8 2 5"
    When I follow "Birmingham"
    Then I should see "7 8 2 5"
    When I follow "Sheffield"
    Then I should not see "7 8 2 5"
    When I follow "All"
    Then I should see "7 8 2 5"