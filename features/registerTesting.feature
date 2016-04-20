Feature: Sign up validation

  Scenario:Empty Firstname
    Given I am on the sign_up page
    When I fill in "firstname" with ""
    When I fill in "surname" with "surname"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your first name"


  Scenario:Empty Surname
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with ""
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your surname"


