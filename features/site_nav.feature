Feature: Accessing specific pages on the website from the navigation bar or url

  Scenario: Successfully accessing pages when not logged in
    Given I am not logged in
    When I follow "Home"
    Then I should be on the home page
    When I follow "Menu"
    Then I should be on menu
    When I follow "How to Order"
    Then I should be on the instructions page
    When I follow "About"
    Then I should be on about
    When I follow "Log In / Sign Up"
    Then I should be on the login page

  Scenario: Successfully accessing pages when logged in as customer
    Given I am logged in as "customer"
    When I follow "Home"
    Then I should be on the home page
    When I follow "Menu"
    Then I should be on menu
    When I follow "How to Order"
    Then I should be on the instructions page
    When I follow "About"
    Then I should be on about
    When I follow "My Account"
    Then I should be on the account page
    When I follow "My Orders"
    Then I should be on customer orders
    When I follow "Log out"
    Then I should see "Thank you visiting us"

  Scenario: Successfully accessing pages when logged in as admin
    Given I am logged in as "admin"
    When I follow "Home"
    Then I should be on the home page
    When I follow "Menu"
    Then I should be on menu
    When I follow "How to Order"
    Then I should be on the instructions page
    When I follow "About"
    Then I should be on about
    When I follow "My Account"
    Then I should be on the account page
    When I follow "Admin Panel"
    Then I should be on the admin panel
    When I follow "Curry House Admin Panel"
    Then I should be on the admin panel
    When I follow "Current Orders"
    Then I should be on orders
    When I follow "Log out"
    Then I should see "Thank you visiting us"

  Scenario: Hiding pages from visitor who are not logged in
    Given I am not logged in
    When I go to the account page
    Then I should be on the home page
    When I go to customer orders
    Then I should be on the home page
    When I go to orders
    Then I should be on the home page
    When I go to the admin panel
    Then I should be on the home page
    When I go to logout
    Then I should not see "Thank you visiting us"
    When I go to the customer info page
    Then I should be on the home page


  Scenario: Hiding pages from customer
    Given I am logged in as "customer"
    When I go to the login page
    Then I should be on the home page
    When I go to the sign_up page
    Then I should be on the home page
    When I go to orders
    Then I should be on the home page
    When I go to the admin panel
    Then I should be on the home page
    When I go to the customer info page
    Then I should be on the home page

  Scenario: Hiding pages from admin
    Given I am logged in as "admin"
    When I go to the login page
    Then I should be on the home page
    When I go to the sign_up page
    Then I should be on the home page
    When I go to customer orders
    Then I should be on the home page

  Scenario: Statistics
    Given I am logged in as admin
    When I go to the admin panel
    And I follow "Statistics"
    Then I should be on the statistics page
    Then I should see "General"
    Then I should see "Today in Curry House:"
    Then I should see "Daily averages:"
    When I follow "Sheffield"
    Then I should be on Sheffield statistics
    When I follow "Birmingham"
    Then I should be on Birmingham statistics