#' List of filters to use with \code{\link{ppo_data}}.
#'
#' A list of the sources, sub-sources, status, traits and genera available and
#' their number of observations in the PPO data portal.
#'
#' @format A list with 5 element:
#' \itemize{
#'   \item{source}{A data set with 1 row and 2 variable:
#'     \itemize{
#'       \item{source}{the source name}
#'       \item{nObs}{the number of obeservations}
#'     }
#'   }
#'   \item{subSource}{A data set with 1 row and 2 variable:
#'     \itemize{
#'       \item{subSource}{the subSource name}
#'       \item{nObs}{the number of obeservations}
#'     }
#'   }
#'   \item{status}{A data set with 1 row and 2 variable:
#'     \itemize{
#'       \item{status}{the status name}
#'       \item{nObs}{the number of obeservations}
#'     }
#'   }
#'   \item{mapped_traits}{A data set with 1 row and 2 variable:
#'     \itemize{
#'       \item{termID}{the term ID}
#'       \item{label}{the term label}
#'       \item{definition}{the term definition from Ontobee}
#'       \item{uri}{the link to the term page from Ontobee}
#'       \item{nObs}{the number of obeservations}
#'       \item{status}{if the term status is 'present' or 'absent; useful to filter by status}
#'       \item{ObjectProperty_termID}{the term for an object propriety in the definition; useful to filter for similar terms}
#'       \item{ObjectProperty_termID1}{the term for a second object propriety in the definition; useful to filter for similar terms}
#'       \item{ObjectProperty_termID2}{the term for a third object propriety in the definition; useful to filter for similar terms}
#'     }
#'   }
#'   \item{genus}{A data set with 1 row and 2 variable:
#'     \itemize{
#'       \item{genus}{the genus name}
#'       \item{nObs}{the number of obeservations}
#'     }
#'   }
#'   ...
#' }
#' @source \url{https://www.ontobee.org}
"ppo_filters"
