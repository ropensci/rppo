#' @title Retrieve phenology terms from PPO
#'
#' @description
#'
#' The get_ppo_terms function returns phenological present or absent class
#' names from the Plant Phenology Ontology.  The returned data frame contains
#' the following columns: stageID, label, description, and URI.  Use the stageID
#' values in submitting stageID values to the \code{\link{get_ppo_data}} function.  The
#' label and description fields are extracted from the ontology OWL file and
#' are useful in determining the proper stage to query on.  The URI field contains
#' a link to the term itself which is useful for determining superclass and
#' subclass relationships for each term.

#' For more information on the PPO ontology itself, we suggest loading the PPO
#' ontology \url{https://github.com/PlantPhenoOntology/ppo} and viewing with
#' protege \url{https://protege.stanford.edu/}
#'
#' @param present TRUE or FALSE. Defaults to TRUE. If TRUE then return all "present" phenological stages from the PPO.  If FALSE then return all "absent" phenological stages.
#' @return data.frame
#' @examples
#' df <- get_ppo_terms(present = TRUE)

# Fetch phenological terms (stages) from the PPO using the plantphenology.org "ppo" service
get_ppo_terms <- function(present = TRUE) {

  # set the base_url for making calls
  base_url <- "http://api.plantphenology.org/v1/ppo/";
  if (present)
      base_url <- paste(base_url,'present/',sep='')
  else
      base_url <- paste(base_url,'absent/',sep='')

  results <- httr::GET(base_url)
  if (results$status_code == 200) {
    print ("retrieving terms....")
    response <- httr::content(results, "text")
    jsonFile <- fromJSON(response)
    df <- data.frame(do.call("rbind",jsonFile))
    return(sapply(df,unlist))
  } else {
    print(paste("uncaught status code",results$status_code))
    warn_for_status(results)
    return(NULL);
  }
}

