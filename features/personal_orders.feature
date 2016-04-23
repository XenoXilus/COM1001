Feature: Tracking orders as an admin

  Scenario: Trying to access the page as an admin
    Given I am logged in as "admin"
    When I go to customer orders
    Then I should be on the home page

  Scenario: Accessing the page as a customer and viewing the table
    Given I am logged in as "customer"
    When I go to customer orders
    Then I should see "Order Id" within ".menu_table"
    Then I should see "Text" within ".menu_table"
    Then I should see "Status" within ".menu_table"
    Then I should see "Select to cancel" within ".menu_table"

  Scenario: Cancelling an order
    Given I am logged in as "customer"
    When I go to customer orders
    When I check "status1"
    And I press "Cancel Orders!"
    Then I should see "Canceled" in the "1" column

  Scenario: Cancelling multiple orders
    Given I am logged in as "customer"
    When I go to customer orders
    When I check "status2"
    When I check "status3"
    When I check "status4"
    And I press "Cancel Orders!"
    Then I should see "Canceled" in the "2" column
    Then I should see "Canceled" in the "3" column
    Then I should see "Canceled" in the "4" column