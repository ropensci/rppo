#'Retrieve data from the Plant Phenology Ontology
#'
#' @param present TRUE or FALSE. Defaults to TRUE. If TRUE then return all "present" phenological stages from the PPO.  If FALSE then return all "absent" phenological stages.
#' @return data.frame
#' @examples
#' df <- ppo_stages(present = TRUE)

# Fetch phenological stages from the PPO using the plantphenology.org "ppo" service
ppo_stages <- function(present = TRUE) {

  # set the base_url for making calls
  base_url <- "http://api.plantphenology.org/v1/ppo/";
  if (present)
      base_url <- paste(base_url,'present/',sep='')
  else
      base_url <- paste(base_url,'absent/',sep='')

  results <- httr::GET(base_url)
  if (results$status_code == 200) {
    print ("retrieving stages ....")
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
