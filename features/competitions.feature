Feature: Triggering retweet competitions as an admin

  Scenario: Viewing the form
    Given I am logged in as admin
    When I go to offers
    Then I should see "Trigger twitter RT giveaway"

  Scenario: Submitting the form with as empty message
    Given I am logged in as admin
    When I go to offers
    When I fill in "msg" with ""
    And I press "Start"
    Then I should see "Message field cannot be empty."

  Scenario: Submitting the form with an invalid deadline
    Given I am logged in as admin
    When I go to offers
    When I fill in "date" with "2010-10-10"
    When I fill in "time" with "21:00"
    And I press "Start"
    Then I should see "Invalid deadline"

  Scenario: Succesfully triggering the competition
    Given I am logged in as admin
    When I go to offers
    When I fill in "msg" with "RT competition"
    When I fill in "date" with "2020-10-10"
    When I fill in "time" with "21:00"
    When I fill in "nwinners" with "1"
    When I fill in "cp_reward" with "10"
    And I press "Start"
    Then I should see "RT competition" within "table#competitions"

  Scenario: Getting winners
    Given I am logged in as admin
    When I go to offers
    When a customer participates in the competition "RT competition"
    When the competition "RT competition" expires
    When I go to winner selection
    Then I should see "the customer account"

  Scenario: Redeeming prize as customer
    Given I am logged in as customer
    Given I won "10" CP from code "ABC" in competition "RT competition"
    When I go to the account page
    When I fill in "code" with ""
    And I press "Redeem"
    Then I should see "The voucher code does not exist."
    When I fill in "code" with "fdjal"
    Then I should see "The voucher code does not exist."
    And I press "Redeem"
    When I fill in "code" with "ABC"
    And I press "Redeem"
    Then I should see "Successfully added 10 CurryPounds."
    When I follow "Go Back."
    When I fill in "code" with "ABC"
    And I press "Redeem"
    Then I should see "The voucher code is already redeemed."
    Then delete competition "RT competition" and code "ABC"