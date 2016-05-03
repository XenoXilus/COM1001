Feature: Selecting branch and viewing branch specific information

  Scenario: Selecting sheffield branch
    Given I am not logged in
    When I go to the home page
    Then I should see "Help Us Deliver To You"
    When I follow "Sheffield Branch"
    Then I should not see "Sheffield Branch"
    Then I should not see "Birmingham Branch"
    Then I should see "Welcome to Curry House Sheffield!"
    When I follow "Menu"
    Then I should see a "Sheffield" item
    When I follow "About"
    Then I should see "Sheffield" within "#city"

  Scenario: Selecting sheffield branch
    Given I am not logged in
    When I go to the home page
    Then I should see "Help Us Deliver To You"
    When I follow "Birmingham Branch"
    Then I should see "Welcome to Curry House Birmingham!"
    When I follow "Menu"
    Then I should see a "Birmingham" item
    When I follow "About"
    Then I should see "Birmingham" within "#city"

  Scenario: Changing branch with "Select Branch"
    Given I am not logged in
    When I go to the home page
    When I follow "Sheffield Branch"
    Then I should see "Select Branch"
    When I follow "Select Branch"
    Then I should see "Help Us Deliver To You"
    When I follow "Birmingham Branch"
    When I follow "Menu"
    Then I should see a "Birmingham" item
    When I follow "About"
    Then I should see "Birmingham" within "#city"

  Scenario: "Select Branch" is not displayed when logged in or when a selection is not made
    Given I am not logged in
    When I go to the home page
    Then I should not see "Select Branch"
    Given I am logged in as "admin"
    Then I should not see "Help Us Deliver To You"
    Given I am not logged in
    Given I am logged in as "customer"
    Then I should not see "Help Us Deliver To You"
