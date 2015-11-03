Feature: User Login

  Scenario: User Login with valid nation slug
    Given I open the walklist page
    When I login with getupstaging
    Then I should be redirected to nation builder page