
<!-- README.md is generated from README.Rmd. Please edit that file -->
rppo
====

[![Build Status](https://travis-ci.org/biocodellc/rppo.svg?branch=master)](https://travis-ci.org/biocodellc/rppo) [![codecov.io](https://codecov.io/github/r-lib/covr/coverage.svg?branch=master)](https://codecov.io/github/r-lib/covr?branch=master) [![in review](https://badges.ropensci.org/%3Cissue_id%3E_status.svg)](https://github.com/ropensci/onboarding/issues/%3C207%3E)

The global plant phenology data portal, or [PPO data portal](https://www.plantphenology.org/), is an aggregation of plant phenological observations from [USA-NPN](https://www.usanpn.org/usa-national-phenology-network), [NEON](https://www.neonscience.org/), and [PEP725](http://www.pep725.eu/) representing 20 million phenological observations from across North America and Europe. The PPO data portal utilizes the [Plant Phenology Ontology](https://github.com/PlantPhenoOntology/ppo/) (PPO) to align phenological terms and measurements from the various databases. The rppo R package enables programmatic access to all data contained in the PPO data portal incuding selected classes contained in the PPO itself.

For more information visit how data is assembled for the PPO data portal, visit the [ppo-data-pipeline git repository](https://github.com/biocodellc/ppo-data-pipeline).

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

We reccomend visiting the [rppo vignette](http://htmlpreview.github.io/?https://github.com/biocodellc/rppo/blob/master/vignettes/rppo-vignette.html) for a set of well-explained examples on using the rppo package, as well as viewing man pages for rppo functions in the R environment, using `?ppo_data` and `?ppo_terms`. Following are a couple of brief examples to illustrate how to get started:

``` r
# query all results from day 1 through 100 in a particular bounding box, 
# limited to 2 records
r <- ppo_data(fromDay = 1, toDay = 100, bbox="37,-120,38,-119", limit=2)
#> sending request for data ...
#> https://www.plantphenology.org/api/v2/download/?q=%2Blatitude:>=37+AND+%2Blatitude:<=38+AND+%2Blongitude:>=-120+AND+%2Blongitude:<=-119+AND+%2BdayOfYear:>=1+AND+%2BdayOfYear:<=100+AND+source:USA-NPN,NEON&source=latitude,longitude,year,dayOfYear,termID&limit=2

# view the data returned
print(r$data)
#>   dayOfYear year   genus specificEpithet latitude longitude
#> 1        33 2017 Quercus       douglasii 37.11144 -119.7315
#> 2        96 2017  Bromus        diandrus 37.11144 -119.7315
#>                                                                                                                                                                                                                                            termID
#> 1                                                                                                                                                                                                 obo:PPO_0002610,obo:PPO_0002013,obo:PPO_0002000
#> 2 obo:PPO_0002601,obo:PPO_0002610,obo:PPO_0002005,obo:PPO_0002604,obo:PPO_0002605,obo:PPO_0002013,obo:PPO_0002003,obo:PPO_0002000,obo:PPO_0002602,obo:PPO_0002006,obo:PPO_0002007,obo:PPO_0002004,obo:PPO_0002008,obo:PPO_0002603,obo:PPO_0002600
#>   source
#> 1   NEON
#> 2   NEON
#>                                                              eventId
#> 1 http://n2t.net/ark:/21547/Amn2cd982ca2-6147-4a63-a864-f4e556420562
#> 2 http://n2t.net/ark:/21547/Amn2d1a3e6de-7885-404f-828f-9ebf63248d68

# view the number of possible records returned
print(r$number_possible)
#> [1] 7251

# return a data frame of present
presentTerms <- ppo_terms(present = TRUE)
#> sending request for terms ...

# print the 2nd present term returned
print(presentTerms[2,])
#>            termID                    label
#> 2 obo:PPO_0002301 new shoot system present
#>                                                                                                                                                                    definition
#> 2 An 'new shoot system presence' (PPO:0002003) trait that is a 'quality of' (RO:0000080) a 'whole plant' (PO:0000003) that has at least one 'new shoot system' (PPO:0001003).
#>                                          uri
#> 2 http://purl.obolibrary.org/obo/PPO_0002301
```

Citation
--------

To cite the 'rppo' R package in publications use:

       'John Deck, Brian Stucky, Ramona Walls, Kjell Bolmgren, Ellen Denny, Robert Guralnick' (2018). rppo: An interface to the Plant Phenology Ontology and associated data store.  R package version 1.0
       https://github.com/biocodellc/rppo

Code of Conduct
---------------

View our [code of conduct](CONDUCT.md)
