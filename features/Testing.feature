# Scenarios go here!
  Feature: Site navigation

    Scenario: Admin login
      Given I am on the login page
      When I fill in "email address" with "admin@ch.com"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      Then I should see "Welcome to Curry House!" within "p"

    Scenario: Wrong password
      Given I am on the login page
      When I fill in "email address" with "admin@ch.com"
      When I fill in "password" with "ihatecurry"
      When I press "submit" within "form"
      Then I should see "The password is not correct." within "p"

    Scenario: Bad email
      Given I am on the login page
      When I fill in "email address" with "nonsenseemail"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      Then I should see "This email address does not exist or it is not correct. Please enter a correct email address." within "p"

    Scenario: Logging out
      Given I am on the login page
      When I fill in "email address" with "admin@ch.com"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      When I press "logout" within "header"
      Then I should see "Thank you visiting us" within "div"

    Scenario: Viewing the menu
      Given I am on the home page
      When I go to menu
      Then I should see "menu"