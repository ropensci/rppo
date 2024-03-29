% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ppo_traits.R
\name{ppo_traits_sort}
\alias{ppo_traits_sort}
\title{Title}
\usage{
ppo_traits_sort(x, flatten_traits = TRUE, flatten_all = FALSE)
}
\arguments{
\item{x}{(object) A list or data.frame as returned from link(rppo)[ppo_traits] with sorted set to FALSE.}

\item{flatten_traits}{(logical) Should the traits list be melted in a data.frame. Default : TRUE}

\item{flatten_all}{(logical) Should the output list be melted in a data.frame. Default : FALSE}
}
\value{
A list for each event id containing a list
        with the following elements:
        \itemize{
         \item {`metadata`: A data frame containing metadata}
         \item {`taxonomy`: A data.frame containing the taxonomy}
         \item {`traits`: if flatten_traits is TRUE, a melted data.frame, else a list
                          containing the traits value}
        }
        IF flatten_all is TRUE, the list is flatten to a data.frame
}
\description{
Title
}
\examples{
r1 <- ppo_data(genus = "Quercus", termID='obo:PPO_0002313', limit=10, timeLimit = 4)
r1_traits <- ppo_traits(r1,  sorted = FALSE)
r1_traits <- ppo_traits_sort(r1_traits)
}
