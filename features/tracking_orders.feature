Feature: Tracking orders as an admin

  Scenario: Trying to access the page as a customer
    Given I am logged in as "customer"
    When I go to orders
    Then I should be on the home page

  Scenario: Accessing the page as admin and viewing the table
    Given I am logged in as "admin"
    When I go to orders
    Then I should see "Order Id" within ".menu_table"
    Then I should see "Tweet Id" within ".menu_table"
    Then I should see "From" within ".menu_table"
    Then I should see "Text" within ".menu_table"
    Then I should see "Status" within ".menu_table"
    Then I should see "Select to change" within ".menu_table"

  Scenario: Displaying new orders
    Given I am logged in as "admin"
    When I go to orders
    When a customer orders "item x"
    When I go to orders
    Then I should see "item x"

  Scenario: Displaying canceled orders from customers
    Given I am logged in as "admin"
    When a customer cancels "item x"
    When I go to orders
    Then I should see "Canceled" in the "item x" column

  Scenario: Changing an order status
    Given I am logged in as "admin"
    When I go to orders
    When I check "status1"
    When I select "Preparing" from "change_to"
    And I press "Change Status!"
    Then I should see "Preparing" in the "1" column

  Scenario: Changing multiple order statuses
    Given I am logged in as "admin"
    When I go to orders
    When I check "status1"
    When I check "status2"
    When I check "status3"
    When I select "Delivering" from "change_to"
    And I press "Change Status!"
    Then I should see "Delivering" in the "1" column
    Then I should see "Delivering" in the "2" column
    Then I should see "Delivering" in the "3" column