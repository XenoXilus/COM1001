Feature:Finding information for customers and administrators at the customer info page from the admin panel

  Scenario: Find customer information from it's twitter
    Given I am logged in as admin
    When I go to the admin panel
    When I go to the customer info page
    When I fill in "input" with "eee"
    When I press "Search"
    Then I should see "Customer 	Customer 	City center 	birmingham 	customer@gmail.com 	eee 	0.0 	YES"

  Scenario: Find customer information from it's Email
    Given I am logged in as admin
    When I go to the admin panel
    When I go to the customer info page
    When I fill in "input" with "customer2@gmail.com"
    When I press "Search"
    Then I should see "customer2 	customer2 	sheffield 	sheffield 	customer2@gmail.com 	customer2 	0.0 	NO"

  Scenario:Search for a non registered customer
    Given I am logged in as admin
    When I go to the admin panel
    When I go to the customer info page
    When I fill in "input" with "nothing"
    When I press "Search"
    Then I should see "There is no such a customer."

    Scenario: Blacklist and Unblacklist a customer
      Given I am logged in as admin
      When I go to the admin panel
      When I go to the customer info page
      When I fill in "input" with "customer@gmail.com"
      When I press "Search"
      When "blacklistButton" button is pressed
      Then I should see "Unblacklist"
      When I follow "Log out"
      When I am on the login page
      When I fill in "email_address" with "customer@gmail.com"
      When I fill in "myPassword" with "654321"
      When I press "Log in" within "form#login-form"
      Then I should see "We are sorry to inform you that your account has been banned from our website."
      Given I am logged in as admin
      When I go to the admin panel
      When I go to the customer info page
      When I fill in "input" with "customer@gmail.com"
      When I press "Search"
      When "blacklistButton" button is pressed
      Then I should see "Blacklist"
      When I follow "Log out"
      When I am on the login page
      When I fill in "email_address" with "customer@gmail.com"
      When I fill in "myPassword" with "654321"
      When I press "Log in" within "form#login-form"
      Then I should see "Welcome to Curry House Birmingham!"


  Scenario: Make and Unmake administrator a customer
    Given I am logged in as admin
    When I go to the admin panel
    When I go to the customer info page
    When I fill in "input" with "customer@gmail.com"
    When I press "Search"
    When "adminButton" button is pressed
    Then I should see "Unmake administrator"
    When I follow "Log out"
    When I am on the login page
    When I fill in "email_address" with "customer@gmail.com"
    When I fill in "myPassword" with "654321"
    When I press "Log in" within "form#login-form"
    When I follow "Admin Panel"
    Then I should be on the admin panel
    When I follow "Log out"
    Given I am logged in as admin
    When I go to the admin panel
    When I go to the customer info page
    When I fill in "input" with "customer@gmail.com"
    When I press "Search"
    When "adminButton" button is pressed
    Then I should see "Make administrator"
    When I follow "Log out"
    When I am on the login page
    When I fill in "email_address" with "customer@gmail.com"
    When I fill in "myPassword" with "654321"
    When I press "Log in" within "form#login-form"
    When I go to the admin panel
    Then I should be on the home page
