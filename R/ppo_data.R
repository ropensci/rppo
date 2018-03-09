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
#' @param limit A numeric value to limit number of records
#' @param offset An offset best used with limit as a way to paginate records
#' @param quiet If true, any informative messages will be suppressed
#' @export
#' @keywords data download
#' @importFrom rjson fromJSON
#' @importFrom plyr rbind.fill
#' @importFrom assertthat assert_that
#' @import httr
#' @return data.frame
#' @examples   
#' # data <- ppo_data(genus = "Quercus", yearFrom = 2017)
#' # data <- ppo_data(bbox = '37.77,-122.46,37.76,-122.47')
#' # fail <- aw_data(scientific_name = "auberti levithorax") # This should fail gracefully

ppo_data <- function(genus = NULL, specificEpithet = NULL, trait = NULL, fromYear = NULL, toYear = NULL, fromDay = NULL, toDay = NULL, bbox = NULL, limit = NULL, offset = NULL, quiet = FALSE) {

	# Check for minimum arguments to run a query
	main_args <- z_compact(as.list(c(genus, specificEpithet, trait, bbox)))
	date_args <- z_compact(as.list(c(fromYear, toYear, fromDay, toDay)))
	arg_lengths <- c(length(main_args), length(date_args))

	if (any(arg_lengths) < 1) {
		stop("Please specify at least 1 query argument")
	}

	# This is a quick call with one result observation requested
	# If all goes well and result set is not greater than 1k, all are retrieved
	base_url <- "https://www.plantphenology.org/api/download/?source=latitude,longitude,year,dayOfYear";
	original_limit <- limit
	args <- z_compact(as.list(c(genus = genus, specificEpithet = specificEpithet, bbox = bbox, fromYear = fromYear, toYear = toYear, fromDay = fromDay, toDay = toDay, limit = 1, offset = offset)))
	results <- GET(base_url, query = args)
	return(results)

	#warn_for_status(results)

	#bin <- content(r, "raw")
	#writeBin(bin, "ppo_results.csv.gz")
#
#	data <- read.table(unz(bin, "ppo_results.csv"))
#	unlink(bin)
#	return(data)
}
z_compact <- function(l) Filter(Negate(is.null), l)

