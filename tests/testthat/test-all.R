context("Test PPO Data Fetching")

test_that("Check that no results returns status code = 204", {
  # Generate a response to use for testing
  response <- ppo_data(
    genus = "ImpossibleGenusName",
    fromYear = 1979,
    toYear = 2017,
    limit = 10,
    bbox = "37,-120,38,-119")

  if (is.null(response)) {
    message("unable to run tests while server is not responding")
  } else {
    expect_true(response$status_code == 204)
  }
})

test_that("Check that PPO data is returned correctly from ppo_data function", {
  # Generate a response to use for testing
  response <- ppo_data(
    genus = "Quercus",
    fromYear = 1979,
    toYear = 2017,
    limit = 10,
    bbox = "38,-119,37,-120", timeLimit = 5)

  if (is.null(response)) {
    message("unable to run tests while server is not responding")
  } else {
	  # there should be five elements in this list
	  expect_true(length(response) == 5)

	  # Check data types on response
    expect_s3_class(response$data, "data.frame")
    expect_s3_class(response$readme, c("character", "ppo_text"))
    expect_s3_class(response$citation, c("character", "ppo_text"))

	  # check that the number of rows returned in data frame is 10
	  expect_true(nrow(response$data) == 10)

	  # calling function by itself should produce error
	  expect_error(ppo_data())

	  # check the data itself.  we constrained to genus=Quercus so the first
	  # row should be Quercus
	  expect_identical(as.character(response$data$genus[1]), "Quercus")
  }
})

context("Test PPO Term Fetching")
test_that("Check that PPO term fetching works", {

  # Error should be generated here
  expect_error(ppo_terms())

  presentResponse <- ppo_terms(present = TRUE, timeLimit = 3)
  absentResponse <- ppo_terms(absent = TRUE, timeLimit = 3)
  allResponse <- ppo_terms(absent = TRUE, present = TRUE, timeLimit = 3)

  if (is.null(presentResponse) || is.null(absentResponse) || is.null(allResponse)) {
        message("unable to run tests while server is not responding")
  } else {

    numPresentClasses <- nrow(presentResponse)
    numAbsentClasses <- nrow(absentResponse)
    numAllClasses <- nrow(allResponse)

    # there should be at least 50 'present' and 'absent' classes
    expect_true(numPresentClasses > 50)
    expect_true(numAbsentClasses > 50)
    # fetching present and absent classes should be ALL classes
    expect_true(numAllClasses == (numPresentClasses + numAbsentClasses))

    # check that termIDs are all unique
    expect_true(length(presentResponse$termID) ==
                length(unique(presentResponse$termID)))

  }

})

