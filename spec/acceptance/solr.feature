Feature: Solr Basics
  Background:
    Given I am using the current environment settings

  Scenario: Successful Response
    Given I search for "sea ice"
    Then I should get a valid response with results