#' @title Access Terms From the FuTRES Ontology for Vertebrate Traits (FOVT)
#'
#' @description Access traits from the FuTRES Ontology for Vertebrate Traits (FOVT)
#'
#' @details
#' The futres_traits function returns terms from the FuTRES Ontology for Vertebrate Traits (FOVT)
#' The response populates a data frame with: termID, label, description, and
#' URI.  Use the termID values in submitting termID values to the
#' \code{\link{futres_data}} function.  The label and description fields are
#' extracted from FOVT and are useful in
#' determining the proper term to query on.  The URI field contains a link to
#' the term itself which is useful for determining superclass and subclass
#' relationships for each term.

#' For more information on the FOVT ontology itself, we suggest loading the FOVT
#' \url{https://github.com/futres/fovt} with
#' protege \url{https://protege.stanford.edu/}
#'
#' @return data.frame
#' @export
#' @keywords trait lookup
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr content
#'
#' @examples
#' traits <- futres_traits()

# Fetch traits from the FOVT 
futres_traits <- function() {

  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/futresapi/v2/fovt/"

  results <- httr::GET(base_url)
  if (results$status_code == 200) {
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
