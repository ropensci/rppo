#' @title Retrieve data from PPO Data portal
#'
#' @description
#' The Global Plant Phenology Data Portal (PPO data portal) is an aggregation
#' of phenology data from several different data sources.  Currently it
#' contains USA-NPN, NEON, and PEP725 data sources.  The PPO data portal
#' harvests data using the ppo-data-pipeline, with code available at
#' \url{https://github.com/biocodellc/ppo-data-pipeline/}.
#' You may also view PPO data portal products online at
#' \url{http://plantphenology.org/}.
#'
#' @param genus a plant genus name
#' @param specificEpithet a plant specific epithet
#' @param termID a termID from the plant phenology ontology, e.g.
#' obo:PPO_0002324.  Use the ppo_terms function in this package to get the
#' relevant IDs for present and absent stages
#' @param fromYear query for years starting from the specified year
#' @param toYear query for years up to and including the specified year
#' @param fromDay query for the day of year starting from the specified day
#' @param toDay query for the day of year up to and including the specified day
#' @param bbox A lat long bounding box. Format is \code{lat,long,lat,long}.
#' Use this website: http://boundingbox.klokantech.com/ to quickly grab a
#' bbox (set format on bottom left to csv and be sure to switch the order from
#' long, lat, long, lat to lat, long, lat, long).
#' @param limit Limit the resultset to the specified number of records
#' @export
#' @keywords data download plant phenology
#' @importFrom plyr rbind.fill
#' @importFrom utils read.csv
#' @importFrom utils untar
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom readr read_file
#' @return list (data.frame data, string readme, string citation)
#' @examples
#' results <- ppo_data(genus = "Quercus", fromYear=1979, toYear=2017, limit=10)
#' my_data_frame <- results$data

ppo_data <- function(
  genus = NULL,
  specificEpithet = NULL,
  termID = NULL,
  fromYear = NULL,
  toYear = NULL,
  fromDay = NULL,
  toDay = NULL,
  bbox = NULL,
  limit = NULL) {

  # source Parameter refers to the data source we want to query for
  # here we limit to only USA-NPN and NEON
  sourceParameter <-
    "source:USA-NPN,NEON"
  # source Argument refers to the fields we want returned
  sourceArgument <-
    "source=latitude,longitude,year,dayOfYear,plantStructurePresenceTypes"
  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/api/v2/download/"

  # Check for minimum arguments to run a query
  main_args <- Filter(
    Negate(is.null),
    (as.list(c(genus, specificEpithet, termID, bbox))))
  date_args <-  Filter(
    Negate(is.null),
    (as.list(c(fromYear, toYear, fromDay, toDay))))
  arg_lengths <- c(length(main_args), length(date_args))
  if (any(arg_lengths) < 1) {
    stop("Please specify at least 1 query argument")
  }
  userParams <- Filter(
    Negate(is.null),
    (as.list(
      c(
        genus = genus,
        specificEpithet = specificEpithet,
        termID = termID,
        bbox = bbox,
        fromYear = fromYear,
        toYear = toYear,
        fromDay = fromDay,
        toDay = toDay)
    )))

  # construct the value following the "q" key
  q <- "q="
  # counter to tell us if we're after 1st record
  counter <- 0
  # loop through all user parameters
  for(key in names(userParams)){
    value<-userParams[key]
    # For multiple arguments, insert AND separator.  Here, we insert html
    # encoding + for spaces
    if (counter > 0) {
      q <- paste(q, "+AND+", sep = "")
    }

    if (key == "fromYear")
      q <- paste(q,'%2B','year:>=',value, sep = "")
    else if (key == "fromDay")
      q <- paste(q,'%2B','dayOfYear:>=',value, sep = "")
    else if (key == "toYear")
      q <- paste(q,'%2B','year:<=',value, sep = "")
    else if (key == "toDay")
      q <- paste(q,'%2B','dayOfYear:<=',value, sep = "")
    else if (key == "termID")
      q <- paste(
        q,'%2B','plantStructurePresenceTypes',':"',value,'"', sep = "")
    else if (key == "bbox") {
      lat1 <- as.numeric(unlist(strsplit(bbox, ","))[1])
      lat2 <- as.numeric(unlist(strsplit(bbox, ","))[3])
      lng1 <- as.numeric(unlist(strsplit(bbox, ","))[2])
      lng2 <- as.numeric(unlist(strsplit(bbox, ","))[4])
      if (lat1 > lat2) {
        minLat <- lat2
        maxLat <- lat1
      } else {
        minLat <- lat1
        maxLat <- lat2
      }
      if (lng1 > lng2) {
        minLng <- lng2
        maxLng <- lng1
      } else {
        minLng <- lng1
        maxLng <- lng2
      }
      q <- paste(q, '%2B', 'latitude', ':>=', minLat, sep = "")
      q <- paste(q, '+AND+%2B', 'latitude', ':<=', maxLat, sep = "")
      q <- paste(q, '+AND+%2B', 'longitude', ':>=', minLng, sep = "")
      q <- paste(q, '+AND+%2B', 'longitude', ':<=', maxLng, sep = "")
    }
    # Begin arguments using +key:value and html encode the + sign with %2B
    else {
      q <- paste(q, '%2B', key, ':', value, sep = "")
    }
    counter <- counter  + 1
  }

  # add the source argument
  q <- paste(q, '+AND+', sourceParameter, sep="")

  # construct the queryURL
  queryUrl <- paste(base_url, '?', q, '&', sourceArgument, sep="")

  # add the limit
  if (!is.null(limit)) {
    queryUrl <- paste(queryUrl, '&limit=', limit, sep="")
  }

  message ('sending request for data ...')
  message(queryUrl)

  # send GET request to the PPO data portal
  results <- httr::GET(queryUrl)
  # PPO data portal returns 204 status code when no results have been found
  if (results$status_code == 204) {
    message ("no results found!")
    return(list(
      "data" = NULL,
      "readme" = NULL,
      "citation" = NULL,
      "number_possible" = 0,
      "status_code" = results$status_code)
    )
  }
  # PPO server returns a 200 status code when results have been found with
  # no server errors
  else if (results$status_code == 200) {
    bin <- httr::content(results, "raw")
    tf <- tempfile()

    # save file to disk
    writeBin(bin, tf)
    untar(tf)

    # data.csv contains all data as comma separated values
    data <- read.csv(
      'ppo_download/data.csv',header=TRUE)
    # README.txt contains information about the query and the # of results
    readme <- readr::read_file(
      'ppo_download/README.txt')
    # citation_and_data_use_policies.txt contains citation information
    citation <- readr::read_file(
      'ppo_download/citation_and_data_use_policies.txt')
    # grab the number possble from the readme file, using the
    # cat function and capturing output so we can grep results
    # (server does not return a usable count at this time)
    numPossible <- strsplit(
      grep(
        "total results possible",
        capture.output(cat(readme)),
        value=TRUE)
      , " = ")
    # convert string version with commas to an integer
    numPossible <- as.numeric(gsub(",", "", sapply(numPossible, `[`,2)))
    unlink(tf)
    unlink("ppo_download/", recursive=TRUE)

    return(list(
      "data" = data,
      "readme" = readme,
      "citation" = citation,
      "number_possible" = numPossible,
      "status_code" = results$status_code)
    )

  }
  # Something unexpected happened
  else {
    message(paste("Ooops!  The server encountered an issue processing your
               request and returned status code = ",results$status_code,
                  ". If the problem persists contact the author."))
    return(list(
      "data"= NULL,
      "readme" = NULL,
      "citation" = NULL,
      "number_possible" = NULL,
      "status_code" = results$status_code))
  }
}


