Feature: Sign up validation

  Scenario:Correct form entry
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Your data have been saved."

  Scenario:Empty Firstname
    Given I am on the sign_up page
    When I fill in "firstname" with ""
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
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
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your surname"

  Scenario:Empty Address
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with ""
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your Address"


  Scenario:Incorrect Email address
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "wrong_email"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your email address correctly"

  Scenario:Already submitted Email address
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "customer@gmail.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "This email already exists."
    Then I should see "Please enter another Email address"


  Scenario:Non existing Twitter
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "unreal_twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "Please enter your Twitter correctly. There is no twitter with the name 'unreal_twitter'"

  Scenario:Already submitted Twitter account
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "atwitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "123456"
    When I press "Submit" within "form"
    Then I should see "This twitter already exists."
    Then I should see "Please enter another twitter"

  Scenario:Small password
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "12345"
    When I fill in "confirm_password" with "12345"
    When I press "Submit" within "form"
    Then I should see "Please enter a password(at least 6 characters)"

  Scenario:Different passwords
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123456"
    When I fill in "confirm_password" with "654321"
    When I press "Submit" within "form"
    Then I should see "The passwords are not the same"


  Scenario:Small and Different passwords
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "12345"
    When I fill in "confirm_password" with "123"
    When I press "Submit" within "form"
    Then I should see "Please enter a password(at least 6 characters)"
    Then I should see "The passwords are not the same"

  Scenario:Small and Different passwords (different order)
    Given I am on the sign_up page
    When I fill in "firstname" with "firstname"
    When I fill in "surname" with "surname"
    When I fill in "address" with "address"
    When I fill in "email" with "email@email.com"
    When I fill in "twitter" with "twitter"
    When I fill in "password" with "123"
    When I fill in "confirm_password" with "12345"
    When I press "Submit" within "form"
    Then I should see "Please enter a password(at least 6 characters)"
    Then I should see "The passwords are not the same"