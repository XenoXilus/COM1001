# Scenarios go here!
  Feature: Login

    Scenario: Admin login
      Given I am on the login page
      When I fill in "email" with "admin@ch.com"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      Then I should see "Welcome to Curry House!"

    Scenario: Wrong password
      Given I am on the login page
      When I fill in "email" with "admin@ch.com"
      When I fill in "password" with "ihatecurry"
      When I press "submit" within "form"
      Then I should see "The password is not correct."

    Scenario: Bad email
      Given I am on the login page
      When I fill in "email" with "nonsenseemail"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      Then I should see "This email address does not exist or it is not correct. Please enter a correct email address."

    Scenario: Logging out
      Given I am on the login page
      When I fill in "email" with "admin@ch.com"
      When I fill in "password" with "123456"
      When I press "submit" within "form"
      When I press "logout" within "navbar"
      Then I should see "Thank you visiting us"
