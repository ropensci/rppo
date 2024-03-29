#' @title Access the Global Plant Phenology Data Portal
#'
#' @description Access data from the global plant phenology data portal
#' (PPO data portal) and phenology terms from the Plant Phenology Ontology
#' (PPO)
#'
#' @details \pkg{rppo} enables users to query the global plant phenology
#' data portal (PPO data portal). The PPO data portal is an aggregation
#' of phenology data from several different data sources.  Currently it
#' contains USA-NPN, NEON, and PEP725 data sources.  The PPO data portal
#' harvests data using the ppo-data-pipeline, with code available at
#' \url{https://github.com/biocodellc/ppo-data-pipeline/}.  All phenological
#' terms in the data portal are aligned using the Plant Phenology Ontology
#' (PPO), available at \url{https://github.com/PlantPhenoOntology/ppo}.
#'
#'
#' Three main functions are contained in the \pkg{rppo}:
#' \code{\link{ppo_terms}} allows users to discover present and absent
#' phenological stages, \code{\link{ppo_data}} enables users to query the
#' PPO data portal and \code{\link{ppo_traits}} use the data fetched from the
#' PPO data portal and return the traits data for each eventID.
#' The \pkg{rppo} package source code is available at
#' \url{https://github.com/ropensci/rppo/}.
"_PACKAGE"
#> [1] "_PACKAGE"
