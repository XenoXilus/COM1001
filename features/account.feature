Feature: Account information modification

  Scenario: Access the account page as admin
    Given I am logged in as "admin"
    When I go to the account page
    Then I should see "Fill the form to update your information."

  Scenario: Access the account page as customer
    Given I am logged in as "customer"
    When I go to the account page
    Then I should see "Fill the form to update your information."

  Scenario: View the account information
    Given I am logged in as "customer"
    When I go to the account page
    Then I should see "First Name"
    Then I should see "Surname"
    Then I should see "Twitter Account"
    Then I should see "Credit Card"
    Then I should see "Address"
    Then I should see "Balance"

  Scenario: Successfully modify information
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "first_name" with "New Name"
    When I fill in "surname" with "New Surname"
    When I fill in "cc" with "1234567812345678"
    When I fill in "address" with "New address"
    When I press "Update Information" within "form"
    Then I should see "The update was succesful."
#    When I go to the account page
#
#    Then I should see "1234567812345678" within "#cc"
#
#    Then I should see "New name"
#    Then I should see "New surname"
#
#    Then I should see "New address"

  Scenario: Remove credit card and address
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "cc" with ""
    When I fill in "address" with ""
    When I press "Update Information" within "form"
    Then I should see "The update was succesful."
    When I go to the account page
    Then I should see "" within "#cc"
    Then I should see "" within "#address"

  Scenario: Enter invalid credit card(not 16 digits)
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "cc" with "123"
    When I press "Update Information" within "form"
    Then I should see "Invalid Credit Card number."

  Scenario: Enter invalid first name and surname
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "first_name" with ""
    When I fill in "surname" with ""
    When I press "Update Information" within "form"
    Then I should see "Invalid value for first name."
    Then I should see "Invalid value for surname."
