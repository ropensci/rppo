#' @title Access Data From the  FuTRES data portal
#'
#' @description Access data from FuTRES
#' (futres data portal)
#'
#' @details
#' The futres_data function returns a list containing the following information:
#' a readme file, citation information, a data frame with data, an integer with
#' the number of records returned and a status code.  The function is called with
#' parameters that correspond to values contained in the data itself which act
#' as a filter on the returned record set.
#'
#' @param genus (string) a plant genus name
#' @param specificEpithet (string) a plant specific epithet
#' @param termID (string) A single termID from the FOVT 
#' See the \code{\link{futres_terms}} function for more information.
#' @param fromYear (integer) return data from the specified year
#' @param toYear (integer) return data up to and including the specified year
#' @param bbox (string) return data within a bounding box. Format is
#' \code{lat,long,lat,long} and is structured as a string.  Use this website:
#' http://boundingbox.klokantech.com/ to quickly grab a bbox (set format on
#' bottom left to csv and be sure to switch the order from
#' long, lat, long, lat to lat, long, lat, long).
#' @param limit (integer) limit returned data to a specified number of records
#' @export
#' @keywords data download vertebrate traits
#' @importFrom plyr rbind.fill
#' @importFrom utils read.csv
#' @importFrom utils untar
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom readr read_file
#' @importFrom utils capture.output

#' @return Return value containing a list with the following components:
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
#' r1 <- futres_data(genus = "Puma", termID='obo:FOVT_0002313', limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data

futres_data <- function(
  genus = NULL,
  specificEpithet = NULL,
  termID = NULL,
  fromYear = NULL,
  toYear = NULL,
  bbox = NULL,
  limit = NULL) {

  # source Argument refers to the fields we want returned
  sourceArgument <-
    "source=latitude,longitude,year,dayOfYear,termID"
  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/futresapi/v2/download/"

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
        toYear = toYear
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
    else if (key == "toYear")
      q <- paste(q,'%2B','year:<=',value, sep = "")
    else if (key == "termID")
      q <- paste(
        q,'%2B','termID',':"',value,'"', sep = "")
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

  # send GET request to the FOVT data portal
  results <- httr::GET(queryUrl)
  # FOVT data portal returns 204 status code when no results have been found
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
  # FOVT server returns a 200 status code when results have been found with
  # no server errors
  else if (results$status_code == 200) {
    bin <- httr::content(results, "raw")
    tf <- tempfile()

    # save file to disk
    writeBin(bin, tf)
    untar(tf)

    # data.csv contains all data as comma separated values
    data <- read.csv(
      'futres_download/data.csv',header=TRUE)
    # README.txt contains information about the query and the # of results
    readme <- readr::read_file(
      'futres_download/README.txt')
    # citation_and_data_use_policies.txt contains citation information
    citation <- readr::read_file(
      'futres_download/citation_and_data_use_policies.txt')
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
    numPossible <- as.numeric(gsub(",", "", lapply(numPossible, `[`,2)))
    unlink(tf)
    unlink("futres_download/", recursive=TRUE)

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
    message(paste("The server encountered an issue processing your
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

