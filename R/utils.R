bc <- function(x) if (!length(x)) NULL else x[lengths(x) > 0]

assert <- function(x, what, name = deparse(substitute(expr = x, env = environment()))) {
  if (length(x)) {
    if (!inherits(x = x, what = what))
      stop(name, " must be of class ", paste0(what, collapse = ", "), call. = FALSE)
    if (length(what) > 1 && "character" %in% what && any(c("integer", "numeric") %in% what))
      if (!grepl("^[0-9]*$", x)) stop(name, " must be coercibled to integer.", call. = FALSE)
  }
  x
}

get_url <- function(queryURL, timeLimit) {
  message('sending request for data ...')
  message(queryURL)
  # send GET request to the PPO data portal
  results = tryCatch({
    results <- httr::GET(queryURL, httr::timeout(timeLimit))
  }, error = function(e) {
    return(NULL)
  })
  # first check if we found anything at the addressed we searched for
  if (is.null(results)) {
    message(paste("The server is not responding.
                    If the problem persists contact the author."))
    # PPO server returns a 200 status code when results have been found with
    # no server errors
  } else if (results$status_code != 200) {
    # PPO data portal returns 204 status code when no results have been found
    if (results$status_code == 204) {
      message("no results found!")
    } else {
      message(paste("The server encountered an issue processing your
             request and returned status code = ",results$status_code,
             ". If the problem persists contact the author."))
    }
  }
  results
}
# print method so the file is readable when printing it
print.ppo_text <- function(x) cat(x)
