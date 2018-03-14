#'Retrieve data from the Global Plant Phenology Ontology Data portal
#'
#' @param genus a plant genus name
#' @param specificEpithet a plant specific epithet
#' @param trait a plant trait
#' @param fromYear query for years starting from this year
#' @param toYear query for years ending at this year
#' @param fromDay query for days starting from this day
#' @param toDay query for days ending at this day
#' @param bbox A lat long bounding box. Format is \code{lat,long,lat,long}. Use this website: http://boundingbox.klokantech.com/ to quickly grab a bbox (set format on bottom left to csv and be sure to switch the order from long, lat, long, lat to lat, long, lat, long)
#' Just set the format on the bottom left to CSV.
#' @export
#' @keywords data download
#' @importFrom rjson fromJSON
#' @importFrom plyr rbind.fill
#' @importFrom assertthat assert_that
#' @import httr
#' @return data.frame
#' @examples
#' # df <- ppo_data(genus = "Quercus", fromYear = 1979, toYear = 1995)
#' # df <- ppo_data(bbox = '37.77,-122.46,37.76,-122.47')

ppo_data <- function(genus = NULL, specificEpithet = NULL, trait = NULL, fromYear = NULL, toYear = NULL, fromDay = NULL, toDay = NULL, bbox = NULL ) {

  # source Parameter refers to the data source we want to query for
  # here we limit to only USA-NPN and NEON
  sourceParameter = "source:USA-NPN,NEON"
  # source Argument refers to the fields we want returned
  sourceArgument = "source=latitude,longitude,year,dayOfYear"

  # Check for minimum arguments to run a query
  main_args <- z_compact(as.list(c(genus, specificEpithet, trait, bbox)))
  date_args <- z_compact(as.list(c(fromYear, toYear, fromDay, toDay)))
  arg_lengths <- c(length(main_args), length(date_args))

  if (any(arg_lengths) < 1) {
    stop("Please specify at least 1 query argument")
  }


  # set the base_url for making calls
  base_url <- "https://www.plantphenology.org/api/download/";
  userParams <- z_compact(as.list(c(genus = genus, specificEpithet = specificEpithet, bbox = bbox, fromYear = fromYear, toYear = toYear, fromDay = fromDay, toDay = toDay)))

  # construct the value following the "q" key
  qArgument <- "q="
  count = 0;   # counter to tell us if we're after 1st record
  # loop through all user parameters
  for(key in names(userParams)){
    value<-userParams[key]
    # For multiple arguments, insert AND separator.  Here, we insert html encoding + for spaces
    if (count > 0) {
      qArgument <- paste(qArgument,"+AND+", sep = "")
    }

    # Format user supplied dates to query
    if (key == "fromYear" || key == "fromDay") {
      value <- paste('>=', value, sep="")
    }
    if (key == "toYear" || key == "toDay") {
      value <- paste('<=',value, sep="")
    }
    # there is no such system fields as from/toYear or from/toDay, only year
    # and dayOfYear fields so we assign the key year to go with the modified >= <= range values
    # above
    if (key == "fromYear" || key == "toYear") {
      key = 'year'
    }
    if (key == "fromDay" || key == "toDay") {
      key = 'dayOfYear'
    }

    # parse bbox argument and construct query by min/max lat/lng
    if (key == "bbox") {
      lat1 = as.numeric(unlist(strsplit(bbox, ","))[1])
      lat2 = as.numeric(unlist(strsplit(bbox, ","))[3])
      lng1 = as.numeric(unlist(strsplit(bbox, ","))[2])
      lng2 = as.numeric(unlist(strsplit(bbox, ","))[4])
      if (lat1 > lat2) {
        minLat = lat2
        maxLat = lat1
      } else {
        minLat = lat1
        maxLat = lat2
      }
      if (lng1 > lng2) {
        minLng = lng2
        maxLng = lng1
      } else {
        minLng = lng1
        maxLng = lng2
      }
      qArgument <- paste(qArgument,'%2B','latitude',':>=',minLat, sep = "")
      qArgument <- paste(qArgument,'+AND+%2B','latitude',':<=',maxLat, sep = "")
      #qArgument <- paste(qArgument,'+AND+%2B','longitude',':>=',minLng, sep = "")
      #qArgument <- paste(qArgument,'+AND+%2B','longitude',':<=',maxLng, sep = "")
    } else {
      # Begin arguments using +key:value and html encode the + sign with %2B
      qArgument <- paste(qArgument,'%2B',key,':',value, sep = "")
    }
    count = count  + 1
  }

  # add the source argument
  qArgument <- paste(qArgument,'+AND+',sourceParameter, sep="")
  # construct the queryURL
  queryUrl <- paste(base_url,'?',qArgument,'&',sourceArgument, sep="")
  # print out parameters
  print (paste('sending request to',queryUrl))
  # send GET request to URL we constructed
  results <- httr::GET(queryUrl)
  # PPO server returns a 204 status code when no results have been found
  if (results$status_code == 204) {
    print ("no results found!");
    return(NULL);
    # PPO server returns a 200 status code when results have been found with no server errors
  } else if (results$status_code == 200) {
    print ("unzipping response and processing data")
    bin <- httr::content(results, "raw")
    tf <- tempfile()

    # save file to disk
    writeBin(bin, tf)
    # read gzipped file and send to data frame
    # the first line in the returned file is a description of the query that we ran
    # the second line in the returned file is the header
    data <- read.csv(gzfile(tf),skip=1,header=TRUE)
    unlink(tf)
    return(data)
    # Something unexpected happened
  } else {
    print(paste("uncaught status code",results$status_code))
    warn_for_status(results)
    return(NULL);
  }
}

z_compact <- function(l) Filter(Negate(is.null), l)
