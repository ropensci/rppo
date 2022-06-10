#' @title Access Terms From the Plant Phenology Ontology
#'
#' @description Access present and absent terms from the Plant Phenology Ontology
#'
#' @details
#' The ppo_terms function returns terms from the Plant Phenology Ontology (PPO).
#' The function only accepts parameters for "present" or "absent" terms.
#' The response populates a data frame with: termID, label, description, and
#' URI.  Use the termID values in submitting termID values to the
#' \code{\link{ppo_data}} function.  The label and description fields are
#' extracted from the Plant Phenology Ontology and are useful in
#' determining the proper term to query on.  The URI field contains a link to
#' the term itself which is useful for determining superclass and subclass
#' relationships for each term.
#' Some of these terms will not return any results when using
#' \code{\link{ppo_data}}.
#' To have only the ones that will return results, use \code{\link{ppo_get_terms}}
#' or check rppo:::ppo_filters$mapped_traits which contains both present
#' and absent terms.

#' For more information on the PPO ontology itself, we suggest loading the PPO
#' \url{https://github.com/PlantPhenoOntology/ppo} with
#' protege \url{https://protege.stanford.edu/}
#'
#' @param present (boolean) If TRUE then return all "present" phenological stages
#' @param absent (boolean) IF TRUE then return all "absent" phenological stages.
#' @param timeLimit (integer) set the limit ofthe amount of time to wait for a response
#' @return data.frame
#' @export
#' @keywords trait lookup
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr content
#'
#' @examples
#' presentTerms <- ppo_terms(present = TRUE, timeLimit = 1)
#'
#' absentTerms <- ppo_terms(absent = TRUE, timeLimit = 1)

# Fetch phenological terms (stages) from the PPO using the plantphenology.org
# "ppo" service
ppo_terms <- function(present=FALSE, absent=FALSE, timeLimit = 4) {
  # args check
  assert(present, "logical")
  assert(absent, "logical")
  assert(timeLimit, c("numeric", "integer"))

  # set the queryURL for making calls
  queryURL <- "https://biscicol.org/api/v1/ppo/"

  # structure base URL so we can call present and absent functions
  if (present && absent) {
    queryURL <- paste(queryURL, 'all/', sep = '')
  } else if (present) {
    queryURL <- paste(queryURL, 'present/', sep = '')
  } else if (absent) {
    queryURL <- paste(queryURL, 'absent/', sep = '')
  } else {
    stop("specify at least one parameter to return results")
  }
  results <- get_url(queryURL = queryURL, timeLimit = timeLimit)
  if (length(results) && results$status_code == 200) {
    jsonlite::fromJSON(httr::content(results, "text"), simplifyVector = TRUE)
  }
}

