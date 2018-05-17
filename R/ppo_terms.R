#' @title Access Terms From the Plant Phenology Ontology
#'
#' @description Access present and absent terms from the Plant Phenology Ontology
#'
#' @details
#' The ppo_terms function returns terms from the Plant Phenology Ontology (PPO).
#' The function only accepts parameters for "present" or "absent" terms.
#' The response pouplates a data frame with: termID, label, description, and
#' URI.  Use the termID values in submitting termID values to the
#' \code{\link{ppo_data}} function.  The label and description fields are
#' extracted from the Plant Phenology Ontology and are useful in
#' determining the proper term to query on.  The URI field contains a link to
#' the term itself which is useful for determining superclass and subclass
#' relationships for each term.

#' For more information on the PPO ontology itself, we suggest loading the PPO
#' \url{https://github.com/PlantPhenoOntology/ppo} with
#' protege \url{https://protege.stanford.edu/}
#'
#' @param present (boolean) If TRUE then return all "present" phenological stages
#' @param absent (boolean) IF TRUE then return all "absent" phenological stages.
#' @return data.frame
#' @export
#' @keywords trait lookup
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr content
#'
#' @examples
#' presentTerms <- ppo_terms(present = TRUE)
#'
#' absentTerms <- ppo_terms(absent = TRUE)
#'
#' presentAndAbsentTerms <- ppo_terms(present = TRUE, absent = TRUE)

# Fetch phenological terms (stages) from the PPO using the plantphenology.org
# "ppo" service
ppo_terms <- function(present=FALSE, absent=FALSE) {

  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/api/v1/ppo/"
  main_args <-  Filter(Negate(is.null), (as.list(c(present,absent))))

  # structure base URL so we can call present and absent functions
  if (present && absent) {
    base_url <- paste(base_url, 'all/', sep='')
  } else if (present) {
    base_url <- paste(base_url, 'present/', sep='')
  } else if (absent) {
    base_url <- paste(base_url, 'absent/', sep='')
  } else {
    stop("specify at least one parameter to return results")
  }

  results <- httr::GET(base_url)
  if (results$status_code == 200) {
    message ("sending request for terms ...")
    response <- httr::content(results, "text")
    jsonFile <- jsonlite::fromJSON(response,simplifyVector= FALSE)
    df <- data.frame(do.call("rbind",jsonFile))
    return(df)
  } else {
    stop(paste("Ooops!  The server encountered an issue processing your
               request and returned status code = ",results$status_code,
               ". If the problem persists contact the author."))
  }
}
