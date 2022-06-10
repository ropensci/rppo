#' @title Access Terms From the Plant Phenology Ontology
#'
#' @description Access present and absent terms from the Plant Phenology Ontology
#'
#' @details
#' The ppo_terms function returns terms from the Plant Phenology Ontology (PPO).
#' The termID or label column  can be used to query the `termID` or
#' `mapped_traits` to \code{\link{ppo_data}}. The label and description
#' columns are useful in determining the trait to query on. The URI column
#' contains a link to the term itself which is useful for determining superclass
#' and subclass relationships for each term.
#'
#' @param present (boolean) If TRUE then return all "present" phenological stages
#' @param absent (boolean) IF TRUE then return all "absent" phenological stages.
#' @return A data frame with the columns: termID, label, description, and URI.
#' @export
#' @keywords trait lookup
#'
#' @examples
#' presentTerms <- ppo_terms(present = TRUE)
#' absentTerms <- ppo_terms(absent = TRUE)
#' allTerms <- ppo_terms(present = TRUE, absent = TRUE)
#' fruitTerms <- grep("fruit", ppo_filters$mapped_traits$label, value = TRUE)
#' ppo_data(genus = c( "Pinus", "Quercus"),
#'          specificEpithet = "palustris",
#'          mapped_traits = fruitTerms,
#'          fromYear = 2016, toYear = 2017)

# Fetch phenological terms (stages) from the PPO using preloaded data from
# plantphenology.org. Returns all the terms ID that can be used with
ppo_get_terms <- function(present=FALSE, absent=FALSE){
  assert(present, "logical")
  assert(absent, "logical")
  queryParams <- c("present", "absent")[c(present, absent)]
  if (!length(queryParams))
    stop("Specify at least one parameter to return results")
  if (length(queryParams) == 2)
    rppo::ppo_filters$mapped_traits[,1:3]
  else
    rppo::ppo_filters$mapped_traits[
      rppo::ppo_filters$mapped_traits$status == queryParams, 1:3
      ]
}
