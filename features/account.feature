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
    Then the "first_name" field should contain "?myname"
    Then the "surname" field should contain "?mysurname"
    Then the "twitter_acc" field should contain "?mytwitter"
    Then the "cc" field should contain "?mycc"
    Then the "address" field should contain "?myaddress"
    Then the "balance" field should contain "?mybalance"

  Scenario: Successfully modify information
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "first_name" with "New name"
    When I fill in "surname" with "New surname"
    When I fill in "cc" with "1234567812345678"
    When I fill in "address" with "New address"
    When I press "Update Information"
    Then I should see "The update was succesful."
    When I follow "Go Back."
    Then the "first_name" field should contain "New name"
    Then the "surname" field should contain "New surname"
    Then the "cc" field should contain "1234567812345678"
    Then the "address" field should contain "New address"

  Scenario: Remove credit card and address
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "cc" with ""
    When I fill in "address" with ""
    When I press "Update Information"
    Then I should see "The update was succesful."
    When I go to the account page
    Then the "cc" field should contain ""
    Then the "address" field should contain ""

  Scenario: Enter invalid credit card(not 16 digits)
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "cc" with "123"
    When I press "Update Information"
    Then I should see "Invalid Credit Card number."

  Scenario: Enter invalid first name and surname
    Given I am logged in as "customer"
    When I go to the account page
    When I fill in "first_name" with ""
    When I fill in "surname" with ""
    When I press "Update Information"
    Then I should see "Invalid value for first name."
    Then I should see "Invalid value for surname."

    Scenario: Successfully adding to the balance
      Given I am logged in as "customer"
      When I go to the account page
      When I fill in "cc" with "1234567812345678"
      When I press "Update Information"
      And I follow "Go Back"
      When I select "5 CP" from "amount"
      And I press "Add to Balance"
      Then I should see "Successfully added 5 CurryPounds."

    Scenario: Successfully adding to the balance
      Given I am logged in as "customer"
      When I go to the account page
      When I fill in "cc" with ""
      When I press "Update Information"
      And I follow "Go Back"
      When I select "5 CP" from "amount"
      And I press "Add to Balance"
      Then I should see "Sorry. We can't process your request if we don't have your Credit Card information."