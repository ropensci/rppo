#' @title Access Data From the Global Plant Phenology Data Portal
#'
#' @description Access data from the global plant phenology data portal
#' (PPO data portal)
#'
#' @param scientificName (character) A plant species scientific name.
#' @param genus (character) A plant genus name. See details.
#' @param specificEpithet (character) A plant specific epithet
#' @param termID (character) A single termID from the plant phenology ontology.
#' See details.
#' @param fromYear (integer) return data from the specified year
#' @param toYear (integer) return data up to and including the specified year
#' @param fromDay (integer) return data starting from the specified day
#' @param toDay (integer) return data up to and including the specified day
#' @param bbox (character) return data within a bounding box. Format is
#' \code{lat,long,lat,long} and is structured as a string.  Use this website:
#' http://boundingbox.klokantech.com/ to quickly grab a bbox (set format on
#' bottom left to csv and be sure to switch the order from
#' long, lat, long, lat to lat, long, lat, long).
#' @param subSource (character) return data from the specified sub-source.
#' See details.
#' @param status (character) Either "present" or "absent". Return data with the
#' specified status.
#' @param mapped_traits (character) return data from the specified traits. See
#' details
#' @param eventRemarks (character) return data from the specified eventRemarks
#' @param limit (integer) limit returned data to a specified number of records
#' @param timeLimit (integer) set the limit of the amount of time to wait for a response
#' @param keepData (logical) whether to keep (TRUE) or delete (FALSE; default)
#' the downloaded data (~/ppo_download/).
#' @param source (character) return data from specified source. Options include
#' ("PEP725", "IMAGE_SCORING", "HERBARIUM" and "USA-NPN"). Set to NULL to not
#' apply this filter.
#' @details
#' The ppo_data function returns a list containing the following information:
#' a readme file, citation information, a data frame with data, an integer with
#' the number of records returned and a status code. The function is called with
#' parameters that correspond to values contained in the data itself which act
#' as a filter on the returned record set. For a list of available mapped_traits,
#' termID, subSource and subSource see the \code{\link{ppo_filters}} dataset. For mapped_traits and
#' termID, the \code{\link{ppo_get_terms}} function will return a data.frame with present,
#' absent or both terms and traits information. The \code{\link{ppo_terms}} will
#' do the same but will use the API to get the lastest data. However, some of
#' the traits/termID may not return any results from this function.
#' See their documentation for more details.
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
#' r1 <- ppo_data(genus = c("Quercus", "Pinus"), termID='obo:PPO_0002313',
#' limit=10, timeLimit = 4)
#' head(r1$data)
#'
#' r2 <- ppo_data(fromDay = 1, toDay = 100, bbox="37,-120,38,-119", limit=10,
#' timeLimit = 4)
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
    limit = 100000L,
    timeLimit = 60,
    keepData = FALSE,
    source = "USA-NPN") {

  # check arguments
  limit <- assert(limit, c("integer", "numeric", "character"))
  if (!length(limit) || as.integer(limit) > 100000) {
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
    source = assert(source, "character"),
    subSource = assert(subSource, "character"),
    status = assert(status, "character"),
    eventRemarks = assert(eventRemarks, "character"),
    mapped_traits = assert(mapped_traits, "character")
  ))
  if (!length(params)) {
    stop("Please specify at least 1 query argument")
  }
  if (length(status) && !status %in% c("present", "absent")) {
    stop("If specified, `status` must be one of 'present' or 'absent'.")
  }
  # for some reason multiple epiphet doesn't work with multiple genus but does
  # with multipule scientificNames
  if (length(genus) > 1 && length(specificEpithet) > 1) {
    if (!length(scientificName)) {
      params$scientificName <- params$genus
      params$genus  <- NULL
    } else {
      warning("Results might not include all queried genus.
              Try specifying genus in scientificName if that's the case.")
    }
  }

  queryURL <- make_queryURL(params = params, limit = limit)

  results <- get_url(queryURL, timeLimit)

  process_response(results = results, keepData = keepData)
}

make_queryURL <- function(params, limit = 100000L) {
  # construct the value following the "q" key
  q <- "q="
  # counter to tell us if we're after 1st record
  counter <- 0
  # loop through all user parameters
  for (key in names(params)) {
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
      coord <- as.numeric(strsplit(value, ",")[[1]])
      lats <- sort(coord[c(1, 3)])
      lngs <- sort(coord[c(2, 4)])
      q <- paste0(q,
                  " latitude:>=", lats[1],
                  " AND  latitude:<=", lats[2],
                  " AND  longitude:>=", lngs[1],
                  " AND  longitude:<=", lngs[2]
      )
    } else {
      if (length(value) > 1) {
        if (key == "scientificName" || key == "specificEpithet")
          value <- paste(value, collapse = "|")
        else
          value <- paste0("(", paste0('"', value, '"', collapse = ","),")")
      }
      q <- paste0(q, ' ', key, ':', value)
    }
    counter <- counter + 1
  }

  queryURL <- paste0("https://biscicol.org/api/v3/download/_search?", q,
                     '&limit=', limit)
  gsub('"', '\\"', gsub(" ", "+", queryURL))
}

process_response <- function(results, keepData = FALSE) {
  if (!length(results) && results$status_code != 200)
      list(
        "data" = NULL,
        "readme" = NULL,
        "citation" = NULL,
        "number_possible" = 0,
        "status_code" = results$status_code)
  else {
    tf <- tempfile()

    # save file to disk
    writeBin(httr::content(results, "raw"), tf)
    unzip(tf, exdir = "~/ppo_download")

    # data.csv contains all data as comma separated values
    ppo <- utils::read.csv('~/ppo_download/data.csv', header = TRUE)

    # README.txt contains information about the query and the # of results
    readme <- readr::read_file('~/ppo_download/README.txt')
    class(readme) <- append(class(readme), "ppo_text")

    # citation_and_data_use_policies.txt contains citation information
    citation <- readr::read_file('~/ppo_download/citation_and_data_use_policies.txt')
    class(citation) <- append(class(citation), "ppo_text")

    # grab the number of possible from the readme file
    numPossible <- gsub("^.*possible = |\ntotal results returned.*$|,",
                        "\\1", readme)
    unlink(tf)
    if (!keepData) unlink("ppo_download/", recursive = TRUE)

    list(
      "data" = ppo,
      "readme" = readme,
      "citation" = citation,
      "number_possible" = as.integer(numPossible),
      "status_code" = results$status_code)
  }
}
