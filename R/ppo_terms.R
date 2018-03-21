#' @title Retrieve phenology terms from PPO
#'
#' @description
#'
#' The ppo_terms function returns terms from the Plant Phenology Ontology.
#' Currently the function only accepts parameters for present or absent terms.
#' The response pouplates a data frame with: termID, label, description, and URI.  Use the termID
#' values in submitting termID values to the \code{\link{ppo_data}} function.  The
#' label and description fields are extracted from the ontology OWL file and
#' are useful in determining the proper term to query on.  The URI field contains
#' a link to the term itself which is useful for determining superclass and
#' subclass relationships for each term.

#' For more information on the PPO ontology itself, we suggest loading the PPO
#' ontology \url{https://github.com/PlantPhenoOntology/ppo} and viewing with
#' protege \url{https://protege.stanford.edu/}
#'
#' @param present If TRUE then return all "present" phenological stages
#' @param absent IF TRUE then return all "absent" phenological stages.
#' @return data.frame
#' @export
#' @keywords trait lookup
#' @importFrom rjson fromJSON
#' @examples
#' presentTerms <- ppo_terms(present = TRUE)
#' absentTerms <- ppo_terms(absent = TRUE)
#' presentAndAbsentTerms <- ppo_terms(present = TRUE, absent = TRUE)

# Fetch phenological terms (stages) from the PPO using the plantphenology.org "ppo" service

ppo_terms <- function(present=FALSE, absent=FALSE) {

  # set the base_url for making calls
  base_url <- "http://api.plantphenology.org/v1/ppo/";

  # structure base URL so we can call present and absent functions
  if (present && absent) {
      base_url <- paste(base_url,'all/',sep='')
  } else if (present) {
      base_url <- paste(base_url,'present/',sep='')
  } else if (absent) {
      base_url <- paste(base_url,'absent/',sep='')
  } else {
      print("specify at least one parameter to return results")
      return(NULL);
  }

  results <- httr::GET(base_url)
  if (results$status_code == 200) {
    print ("retrieving terms ...")
    response <- httr::content(results, "text")
    jsonFile <- rjson::fromJSON(response)
    df <- data.frame(do.call("rbind",jsonFile))
    return(sapply(df,unlist))
  } else {
    print(paste("uncaught status code ",results$status_code))
    warn_for_status(results)
    return(NULL);
  }
}

