
context("PPO data")

test_that("Check that PPO data is returned correctly from ppo_data function", {
	# Generate a response to use for testing
	response <- ppo_data(genus = "Quercus", fromYear = 1979, toYear = 2017, limit=10)

	# there should be three elements in this list
	expect_true(length(response) == 3)

	# Check data types on response
	expect_is(response$data, "data.frame")
	expect_is(response$readme, "character")
	expect_is(response$citation, "character")

	# check that the number of rows returned in data frame is 10
	expect_true(nrow(response$data) == 10)

	# calling function by itself should produce error
	expect_error(ppo_data())

	# check the data itself.  we constrained to genus=Quercus so the first
	# row should be Quercus
	expect_identical(as.character(response$data$genus[1]), "Quercus")
})

context("PPO terms")
test_that("Check that PPO term fetching works", {

  # Error should be generated here
  expect_error(ppo_terms())

  response <- ppo_terms(present = TRUE)

  # there should be at least 50 'present' classes
  expect_true(nrow(response) > 50)

  # check that termIDs are all unique
  expect_true(length(response$termID) == length(unique(response$termID)))

})

