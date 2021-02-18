
context("Test FuTRES Data Fetching")

test_that("Check that no results returns status code = 204", {
  # Generate a response to use for testing
  response <- futres_data(
    genus = "ImpossibleGenusName",
    fromYear = 1979,
    toYear = 2017,
    limit=10,
    bbox="37,-120,38,-119")

  expect_true(response$status_code == 204)
})

test_that("Check that FuTRES data is returned correctly from futres_data function", {
  # Generate a response to use for testing
  response <- futres_data(
    genus = "Puma",
    limit=10)


	# there should be five elements in this list
	expect_true(length(response) == 5)

	# Check data types on response
	expect_is(response$data, "data.frame")
	expect_is(response$readme, "character")
	expect_is(response$citation, "character")

	# check that the number of rows returned in data frame is 10
	expect_true(nrow(response$data) == 10)

	# calling function by itself should produce error
	expect_error(futres_data())

	# check the data itself.  we constrained to genus=Quercus so the first
	# row should be Quercus
	expect_identical(as.character(response$data$genus[1]), "Puma")
})

context("Test FOVT Trait Fetching")
test_that("Check that FOVT term fetching works", {

  # Error should be generated here
  expect_error(futres_traits())

  response <- futres_traits()

  numAllClasses <- nrow(response)

  # fetching all classes should be more than 50
  expect_true(numAllClasses > 50) 

  # check that termIDs are all unique
  expect_true(length(response$termID) ==
                length(unique(response$termID)))

})

