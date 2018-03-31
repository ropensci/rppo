
<!-- README.md is generated from README.Rmd. Please edit that file -->
rppo
====

[![Build Status](https://travis-ci.org/biocodellc/rppo.svg?branch=master)](https://travis-ci.org/biocodellc/rppo)

The global plant phenology data portal (PPO data portal) is an aggregation of plant phenological observations from [USA-NPN](https://www.usanpn.org/usa-national-phenology-network), [NEON](https://www.neonscience.org/), and [PEP725](http://www.pep725.eu/) representing 20 million phenological observations from across North America and Europe. The PPO data portal utilizes the [Plant Phenology Ontology](https://github.com/PlantPhenoOntology/ppo/) to align phenological terms and measurements from the various databases. The rppo R package enables programmatic access to all data contained in the PPO data portal.

For more information visit the [PPO global data portal](http://plantphenology.org/) or the [ppo-data-pipeline git repository](https://github.com/biocodellc/ppo-data-pipeline).

Installation
------------

The production version of rppo can be installed with (when available on CRAN):

``` r
#install.packages("rppo")  # this will work once package is available on CRAN
#library(rppo)
```

You can install the development version of rppo from github with:

``` r
install.packages("devtools")
devtools::install_github("biocodellc/rppo")
```

Install the library once it has been downloaded from CRAN or github.

``` r
library(rppo)
```

Examples
--------

Instructions on using the rppo package can be found using the [rppo vignette](vignettes/rppo-vignette.md). The rppo package contains just two functions. One to query terms from the PPO and another to query the data. Following are examples in how to use these functions.

### ppo\_terms function

A critical element of querying the PPO Data Portal is understanding the present and absent value terms contained in the PPO. The ppo\_terms function returns present terms, absent terms, or both, returning a termID, label, definition and full URI for each term. Use the termIDs returned from this function to query terms in the ppo\_data function. The following example returns the present terms into a "present\_terms" data frame.

``` r
present_terms <- ppo_terms(present=TRUE)
#> [1] "sending request for terms ..."
```

### ppo\_data function

The ppo\_data function queries the PPO Data Portal, passing values to the database and extracting matching results. The results of the ppo\_data function are returned as a lis with three elements: 1) a data frame containing data, 2) a readme string containing usage information and some statistics about the query itself, and 3) a citation string containing information about proper citation.

``` r
results <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110,termID='obo:PPO_0002313', limit=10)
#> [1] "sending request for data ..."
df <- results$data
readme <- results$readme
citation <- results$citation

# use cat(readme) and cat(citation) to view the text output
```

Citation
--------

To cite the 'rppo' R package in publications use:

       'John Deck, Brian Stucky, Ramona Walls, Kjell Bolmgren, Ellen Denny, Robert Guralnick' (2018). rppo: An interface to the Plant Phenology Ontology and associated data store.  R package version 1.0
       https://github.com/biocodellc/rppo

Code of Conduct
---------------

View our [code of conduct](CONDUCT.md)
