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
  
  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/api/v2/ppo/"
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
  
  results = tryCatch({      
      results <- httr::GET(base_url, httr::timeout(timeLimit))      
  }, error = function(e) {      
      return(NULL)
  })
  # first check if we found anything at the addressed we searched for
  if (is.null(results)) {
      message(paste("The server is not responding.  If the problem persists contact the author.  You may also try increasing the timeLimit parameter."))
      return(NULL)
  } else {
    if ( results$status_code == 200) {
          message ("sending request for terms ...")
          response <- httr::content(results, "text")
          jsonFile <- jsonlite::fromJSON(response,simplifyVector= FALSE)
          df <- data.frame(do.call("rbind",jsonFile))
          return(df)
    } else {
          message(paste("The server encountered an issue processing your
               request and returned status code = ",results$status_code,
               ". If the problem persists contact the author."))
        return(NULL)
    }
  }

}
