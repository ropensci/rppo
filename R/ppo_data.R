#' @title Access Data From the Global Plant Phenology Data Portal
#'
#' @description Access data from the global plant phenology data portal
#' (PPO data portal)
#'
#' @details
#' The ppo_data function returns a list containing the following information:
#' a readme file, citation information, a data frame with data, an integer with
#' the number of records returned and a status code.  The function is called with
#' parameters that correspond to values contained in the data itself which act
#' as a filter on the returned record set.
#'
#' @param scientificName (character) A plant species scientific name.
#' @param genus (character) A plant genus name
#' @param specificEpithet (character) A plant specific epithet
#' @param termID (character) A single termID from the plant phenology ontology.
#' See the \code{\link{ppo_terms}} function for more information.
#' @param fromYear (integer) return data from the specified year
#' @param toYear (integer) return data up to and including the specified year
#' @param fromDay (integer) return data starting from the specified day
#' @param toDay (integer) return data up to and including the specified day
#' @param bbox (character) return data within a bounding box. Format is
#' \code{lat,long,lat,long} and is structured as a string.  Use this website:
#' http://boundingbox.klokantech.com/ to quickly grab a bbox (set format on
#' bottom left to csv and be sure to switch the order from
#' long, lat, long, lat to lat, long, lat, long).
#' @param limit (integer) limit returned data to a specified number of records
#' @param timeLimit (integer) set the limit of the amount of time to wait for a response
#' @export
#' @keywords data download plant phenology
#' @importFrom utils read.csv
#' @importFrom utils unzip
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom readr read_file

#' @return A list with the following elements:
#' \itemize{
#'  \item {`data`: A data frame containing data}
#'  \item {`readme`: A string with information about the return package}
#'  \item {`citation`: A string with citation information}
#'  \item {`number_possible`: An integer with total possible results}
#'  \item {`status_code`: An integer with status code returned from server}
#'}
#'
#' @examples
#'
#' r1 <- ppo_data(genus = "Quercus", termID='obo:PPO_0002313', limit=10, timeLimit = 4)
#' head(r1$data)
#'
#' r2 <- ppo_data(fromDay = 1, toDay = 100, bbox="37,-120,38,-119", limit=10, timeLimit = 4)
#' head(r2$data)

ppo_data <- function(
    scientificName = NULL,
    genus = NULL,
    specificEpithet = NULL,
    termID = NULL,
    fromYear = NULL,
    toYear = NULL,
    fromDay = NULL,
    toDay = NULL,
    bbox = NULL,
    subSource = NULL,
    status = NULL,
    mapped_traits = NULL,
    eventRemarks = NULL,
    limit = NULL,
    timeLimit = 60,
    keepData = FALSE) {

  # check arguments
  limit <- assert(limit, c("integer", "numeric", "character"))
  if(!length(limit) || as.integer(limit) > 100000){
    limit <- 100000L
    warning("Maximum value for limit is 100000. Limiting query at 100000.")
  }
  assert(timeLimit, c("integer", "numeric", "character"))
  assert(keepData, "logical")
  # Check for minimum arguments to run a query
  params <- bc(list(
    scientificName = assert(scientificName, "character"),
    genus = assert(genus, "character"),
    specificEpithet = assert(specificEpithet, "character"),
    termID = assert(termID, "character"),
    fromYear = assert(fromYear, c("integer", "numeric", "character")),
    toYear = assert(toYear, c("integer", "numeric", "character")),
    fromDay = assert(fromDay, c("integer", "numeric", "character")),
    toDay = assert(toDay, c("integer", "numeric", "character")),
    bbox = assert(bbox, "character"),
    subSource = assert(subSource, "character"),
    status = assert(status, "character"),
    eventRemarks = assert(eventRemarks, "character"),
    mapped_traits = assert(mapped_traits, "character")
  ))
  if (!length(params)) {
    stop("Please specify at least 1 query argument")
  }
  if(length(status) && !status %in% c("present", "absent")){
    stop("If specified, `status` must be one of 'present' or 'absent'.")
  }
  # for some reason multiple epiphet doesn't work with multiple genus but does
  # with multipule scientificNames
  if(length(genus)>1 && length(specificEpithet)>1){
    if(!length(scientificName)){
      params$scientificName <- params$genus
      params$genus  <- NULL
    } else {
      warning("Results might not include all queried genus.
              Try specifying genus in scientificName if that's the case.")
    }
  }
  params$source <- "USA-NPN"

  queryUrl <- make_queryUrl(params = params, limit = limit)

  message ('sending request for data ...')
  message(queryUrl)

  # send GET request to the PPO data portal
  results = tryCatch({
    results <- httr::GET(queryUrl, httr::timeout(timeLimit))
  }, error = function(e) {
    return(NULL)
  })

  process_response(results, keepData = keepData)
}

make_queryUrl <- function(params, limit = 100000L){
  ## declare queryUrl
  ## unecessary in R
  # queryUrl <- NULL
  ## source Parameter refers to the data source we want to query for
  ## will be formated like other params
  ## sourceParameter <- "source:USA-NPN"
  ## source Argument refers to the fields we want returned
  ## this doesn't seem to change anything ?
  ## sourceArgument <-
  ##   "source=latitude,longitude,year,dayOfYear,termID"

  # set the base_url for making calls
  # base_url <- "https://biscicol.org/api/v3/download/_search"

  # construct the value following the "q" key
  q <- "q="
  # counter to tell us if we're after 1st record
  counter <- 0
  # loop through all user parameters
  for(key in names(params)){
    value <- params[[key]]
    # For multiple arguments, insert AND separator.  Here, we insert html
    if (counter > 0) {
      q <- paste(q, "  AND  ", sep = "")
    }
    # Begin arguments using  key:value and html encode the   sign with
    # Here, we insert html encoding   for spaces
    if (key == "fromYear")
      q <- paste0(q,' year:>=', value)
    else if (key == "toYear")
      q <- paste0(q,' year:<=', value)
    else if (key == "fromDay")
      q <- paste0(q,' dayOfYear:<=', value)
    else if (key == "toDay")
      q <- paste0(q,' dayOfYear:<=', value)
    else if (key == "termID")
      q <- paste(
        q,' ','termID',':"',value,'"', sep = "")
    else if (key == "bbox") {
      coord <- as.numeric(strsplit(bbox, ",")[[1]])
      lats <- sort(coord[1:3])
      lngs <- sort(coord[2:4])
      # lat1 <- as.numeric(unlist(strsplit(bbox, ","))[1])
      # lat2 <- as.numeric(unlist(strsplit(bbox, ","))[3])
      # lng1 <- as.numeric(unlist(strsplit(bbox, ","))[2])
      # lng2 <- as.numeric(unlist(strsplit(bbox, ","))[4])
      # if (lat1 > lat2) {
      #   minLat <- lat2
      #   maxLat <- lat1
      # } else {
      #   minLat <- lat1
      #   maxLat <- lat2
      # }
      # if (lng1 > lng2) {
      #   minLng <- lng2
      #   maxLng <- lng1
      # } else {
      #   minLng <- lng1
      #   maxLng <- lng2
      # }
      q <- paste0(q,
                  " latitude:>=", lats[1],
                  " AND  latitude:<=", lats[2],
                  " AND  longitude:>=", lngs[1],
                  " AND  longitude:<=", lngs[2]
      )
      # q <- paste(q, ' ', 'latitude', '%3A%3E%3D', minLat, sep = "")
      # q <- paste(q, ' AND  ', 'latitude', '%3A%3C%3D', maxLat, sep = "")
      # q <- paste(q, ' AND  ', 'longitude', '%3A%3E%3D', minLng, sep = "")
      # q <- paste(q, ' AND  ', 'longitude', '%3A%3C%3D', maxLng, sep = "")
    } else {
      if(key == "scientificName" || key == "specificEpithet")
        value <- paste(value, collapse = "|")
      else if(key == "genus")
        value <- paste(value, collapse = "+")
      else
        value <- paste0('"', value, '"', collapse = "+")
      q <- paste0(q, ' ', key, ':', value)
    }
    counter <- counter + 1
  }

  # # add the source argument
  # q <- paste(q, ' AND ', sourceParameter, sep="")
  ## construct the queryUrl
  queryUrl <- paste0("https://biscicol.org/api/v3/download/_search?", q,
                     '&limit=', limit)
  gsub('"', '\\"', gsub(" ", "+", queryUrl))
}

process_response <- function(results, keepData = FALSE){
  # first check if we found anything at the addressed we searched for
  if (is.null(results)) {
    message(paste("The server is not responding.
                    If the problem persists contact the author."))
    NULL
    # PPO server returns a 200 status code when results have been found with
    # no server errors
  } else if (results$status_code != 200) {
    # PPO data portal returns 204 status code when no results have been found
    if(results$status_code == 204){
      message ("no results found!")
    } else {
      message(paste("The server encountered an issue processing your
             request and returned status code = ",results$status_code,
             ". If the problem persists contact the author."))
    }
    list(
      "data" = NULL,
      "readme" = NULL,
      "citation" = NULL,
      "number_possible" = 0,
      "status_code" = results$status_code)
  } else {
  tf <- tempfile()

  # save file to disk
  writeBin(httr::content(results, "raw"), tf)
  unzip(tf, exdir="./ppo_download")

  # data.csv contains all data as comma separated values
  ppo <- utils::read.csv('ppo_download/data.csv',header=TRUE)
  #data <- read.csv( paste(tf,'data.csv',sep="/"),header=TRUE)

  # README.txt contains information about the query and the # of results
  readme <- readr::read_file('ppo_download/README.txt')
  #readme <- readr::read_file(paste(tf,'/README.txt'),sep="/")

  # citation_and_data_use_policies.txt contains citation information
  citation <- readr::read_file('ppo_download/citation_and_data_use_policies.txt')
  #citation <- readr::read_file(paste(tf,'/citation_and_data_use_policies.txt',sep="/"))

  # grab the number of possible from the readme file
  ## unecessary
  ## , using the cat function and capturing output so we can grep results
  # (server does not return a usable count at this time)
  # numPossible <- strsplit(
  #   grep(
  #     "total results possible",
  #     capture.output(cat(readme)),
  #     value=TRUE)
  #   ," = ")
  # # convert string version with commas to an integer
  # numPossible <- as.numeric(gsub(",", "", lapply(numPossible, `[`,2)))
  numPossible <- gsub("^.*possible = |\ntotal results returned.*$|,",
                      "\\1", readme)
  unlink(tf)
  if(!keepData) unlink("ppo_download/", recursive=TRUE)

  list(
    "data" = ppo,
    "readme" = structure(readme, class = "ppo_text"),
    "citation" = structure(citation, class = "ppo_text"),
    "number_possible" = as.integer(numPossible),
    "status_code" = results$status_code)
  }
}
