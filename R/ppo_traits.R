#' Get the traits data from the [ppo_data()] event ids.
#'
#' @param x              (object) As returned from link(rppo)[ppo_data]
#' @param sorted         (logical) Should the output traits be sorted by category. Default : TRUE
#' @param flatten_traits (logical) Should the traits list be melted in a data.frame. Default : TRUE
#' @param flatten_all    (logical) Should the output list be melted in a data.frame. Default : FALSE
#'
#' @return If sorted is TRUE, a list for each event id containing a list
#'         with the following elements:
#'         \itemize{
#'          \item {`metadata`: A data frame containing metadata}
#'          \item {`taxonomy`: A data.frame containing the taxonomy}
#'          \item {`traits`: if flatten_traits is TRUE, a melted data.frame, else a list
#'                           containing the traits value}
#'         }
#'         Else, a list of data.frames for each event id.
#'         IF flatten_all is TRUE, the list is flatten to a data.frame
#' @export
#'
#' @examples
#' r1 <- ppo_data(genus = "Quercus", termID='obo:PPO_0002313', limit=10, timeLimit = 4)
#' r1_traits <- ppo_traits(r1)
ppo_traits <- function(x, sorted = TRUE, flatten_traits = TRUE, flatten_all = FALSE){
  out <- lapply(gsub("^.*/([0-9]*)$", "\\1", x$data$eventId[1:2]), function(id){
    x <- jsonlite::read_json(
      paste0(
        "http://www.usanpn.org/npn_portal/observations/getObservationById.json?request_src=PPO&observation_id=",
        id), simplifyVector = T
    )
    if(sorted)
      x <- ppo_sort_traits(x, flatten_traits, flatten_all)
    x
  })
  if(flatten_all)
    as.data.frame(data.table::rbindlist(out))
  else
    structure(out, sorted = sorted, flatten_traits = flatten_traits, flatten_all = flatten_all)
}

#' Title
#'
#' @param x              (object) A list or data.frame as returned from link(rppo)[ppo_traits] with sorted set to FALSE.
#' @param flatten_traits (logical) Should the traits list be melted in a data.frame. Default : TRUE
#' @param flatten_all    (logical) Should the output list be melted in a data.frame. Default : FALSE
#'
#' @return A list for each event id containing a list
#'         with the following elements:
#'         \itemize{
#'          \item {`metadata`: A data frame containing metadata}
#'          \item {`taxonomy`: A data.frame containing the taxonomy}
#'          \item {`traits`: if flatten_traits is TRUE, a melted data.frame, else a list
#'                           containing the traits value}
#'         }
#'         IF flatten_all is TRUE, the list is flatten to a data.frame
#' @export
#'
#' @examples
#' r1 <- ppo_data(genus = "Quercus", termID='obo:PPO_0002313', limit=10, timeLimit = 4)
#' r1_traits <- ppo_traits(r1,  sort = FALSE)
#' r1_traits <- ppo_traits_sort(r1_traits)
ppo_traits_sort <- function(x, flatten_traits = TRUE, flatten_all = FALSE){
  if(attr(x, "sorted")) return(x)
  if(is.list(x) && ! is.data.frame(x)) {
    out <- lapply(x, ppo_traits_sort, flatten_traits = flatten_traits,
                  flatten_all = flatten_all)
    if(flatten_all)
      out <- as.data.frame(data.table::rbindlist(out))
  } else {
    meta <- c(grep("^obs|^sub|^update|^individual|^data", names(x), value = TRUE),
              "site_id", "site_name", "latitude", "longitude", "elevation_in_meters", "state",
              "usda_plants_symbol", "itis_number", "plant_nickname",
              "partner_group", "patch", "protocol_id", "status_conflict_related_records", "day_of_year")
    ranks <- c("kingdom", "class_id", "class_name", "class_common_name",
               "order_id", "order_name", "order_common_name",
               "family_id", "family_name", "family_common_name",
               "genus", "genus_id", "genus_common_name",
               "species_id", "species", "common_name")
    traits <- list(
      phenophase = as.list(x[c(grep("^pheno", names(x)))]),
      temp = as.list(x[c(grep("^tm", names(x)))]),
      intensity = as.list(x[c(grep("^intensity", names(x)))]),
      gdd = as.list(x[c(grep("^gdd", names(x)))]),
      prcp = as.list(x[c(grep("^prcp|pcrp$", names(x)))]),
      maturity = as.list(x[c(grep("^maturity", names(x)))]),
      green = as.list(x[c(grep("^midgreen|^green", names(x)))]),
      senescence = as.list(x[c(grep("^senescence", names(x)))]),
      dormancy = as.list(x[c(grep("^dormancy", names(x)))]),
      peak = as.list(x[c(grep("^peak", names(x)))]),
      evi = as.list(x[c(grep("^evi", names(x)))]),
      qa = as.list(x[c(grep("^qa", names(x)))]),
      other = as.list(x[names(x) %in% c("species_functional_type", "species_category", "lifecycle_duration", "growth_habit", "numcycles", "daylength")])
    )
    if(flatten_traits){
      traits <- reshape2::melt(traits)[c(3:1)]
      colnames(traits) <- c("category", "name", "value")
    }
    metadata <- x[meta[meta %in% names(x)]]
    taxonomy <- x[ranks[ranks %in% names(x)]]
    rownames(metadata) <- rownames(taxonomy) <- rownames(traits) <- NULL
    out <- list(
      metadata = metadata,
      taxonomy = taxonomy,
      traits = traits
    )
    if(flatten_all)
      out <- do.call(cbind.data.frame, out)
  }
  structure(out, sorted = TRUE, flatten_traits = flatten_traits, flatten_all = flatten_all)
}

#' Turn the traits element or the entire list returned by [pp_traits()]
#' into a data.frame.
#'
#' @param x              (object) A list or data.frame as returned from link(rppo)[ppo_traits]
#' @param flatten_all    (logical) Should the output list be melted in a data.frame. Default : FALSE
#'
#' @return @return A list for each event id containing a list
#'         with the following elements:
#'         \itemize{
#'          \item {`metadata`: A data frame containing metadata}
#'          \item {`taxonomy`: A data.frame containing the taxonomy}
#'          \item {`traits`: A melted data.frame containing the traits value}
#'         }
#'         IF flatten_all is TRUE, the list is flatten to a data.frame
#' @export
#'
#' @examples
#' r1_traits <- ppo_traits(r1,  sort = FALSE, flatten_traits = FALSE)
#' r1_traits <- ppo_traits_flatten(r1_traits, flatten_all = TRUE)
ppo_traits_flatten <- function(x, flatten_all = FALSE){
  if(is.data.frame(x))
    x <- list(x)
  out <- lapply(x, function(y){
    if(is.data.frame(y)){
      y <- ppo_traits_sort(y, flatten_traits = TRUE)
    }else if(!is.data.frame(y$traits)){
      y$traits <- reshape2::melt(y$traits)[c(3:1)]
      colnames(y$traits) <- c("category", "name", "value")
      # if(y$traits$name[1] == y$traits$name[2])
    }
    rownames(y$metadata) <- rownames(y$taxonomy) <- rownames(y$traits) <- NULL
    if(flatten_all)
      y <- do.call(cbind.data.frame, y)
    y
  })
  if(flatten_all)
    out <- as.data.frame(data.table::rbindlist(out))
  structure(out, sorted = TRUE, flatten_traits = TRUE, flatten_all = flatten_all)
}
