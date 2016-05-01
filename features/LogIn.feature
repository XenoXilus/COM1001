Feature: Site navigation

  Scenario: Admin login
    Given I am on the login page
    When I fill in "email_address" with "admin@ch.com"
    When I fill in "myPassword" with "123456"
    When I press "Log in" within "form#login-form"
    Then I should see "Welcome to Curry House Birmingham!"

  Scenario: Wrong password
    Given I am on the login page
    When I fill in "email_address" with "admin@ch.com"
    When I fill in "myPassword" with "ihatecurry"
    When I press "Log in" within "form#login-form"
    Then I should see "The password is not correct."

  Scenario: Bad email
    Given I am on the login page
    When I fill in "email_address" with "nonsenseemail"
    When I fill in "myPassword" with "123456"
    When I press "Log in" within "form#login-form"
    Then I should see "This email address does not exist or it is not correct. Please enter a correct email address."

  Scenario: Logging out
    Given I am on the login page
    When I fill in "email_address" with "admin@ch.com"
    When I fill in "myPassword" with "123456"
    When I press "Log in" within "form#login-form"
    When I follow "Log out"
    Then I should see "Thank you visiting us"

  Scenario: Customer login from Birmingham
    Given I am on the login page
    When I fill in "email_address" with "customer@gmail.com"
    When I fill in "myPassword" with "654321"
    When I press "Log in" within "form#login-form"
    Then I should see "Welcome to Curry House Birmingham!"


  Scenario: Customer login from Sheffield
    Given I am on the login page
    When I fill in "email_address" with "customer2@gmail.com"
    When I fill in "myPassword" with "123456"
    When I press "Log in" within "form#login-form"
    Then I should see "Welcome to Curry House Sheffield!"