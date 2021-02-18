
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfutres

The Functional Trait Resource for Environmental Studies, or [FuTRES](https://www.futres.org/), is an aggregation of vertebrate traits from 
[Vertnet](http://vertnet.org/) and other datasets that have been harvested as part of the FuTRES project.
The FuTRES project utilizes the
utilizes the [FuTRES Ontology for Vertebrate Traits](https://github.com/futres/fovt) (FOVT) to align
trait terms from the various databases. The rfutres
R package enables programmatic access to all data contained in the FuTRES
data portal incuding selected classes contained in the fovt ontology.

For information on how data is assembled for the PPO data portal, visit
the [fovt-data-pipeline git
repository](https://github.com/futres/fovt-data-pipeline).

## Installation

The production version of rfovt will be accessible on CRAN. (NOTE: it is not YET published there), but the following provided for reference:

``` r
install.packages("rfovt")  
#> installing the source package 'rfovt'
library(rfovt)
```

You can install the development version of rfutres from github with:

``` r
install.packages("devtools")
devtools::install_github("futres/rfutres")
library(rfutres)
```

## Examples

Following are a couple of brief examples to illustrate how to get
started with rfutres. We recommend visiting the [rfutres
vignette](https://htmlpreview.github.io/?https://github.com/futres/rfutres/blob/master/vignettes/rfutres-vignette.html)
for a more complete set of examples on using the rfutres package, as well
as viewing man pages for rfutres functions in the R environment, using
`?futres_data` and
`?futres_traits`.

``` r
# query all results from day 1 through 100 in a particular bounding box, 
# limited to 2 records
r <- futres_data(fromYear = 2000, toYear = 2010, limit=2)
#> sending request for data ...
# TODO: change request syntax and print

# view the data returned
print(r$data)
# TODO: change display result

# view the number of possible records returned
print(r$number_possible)
#> [1] 7251

# return a data frame of traits
traits <- futres_traits()
#> sending request for traits ...

# TODO: grab output
# print the 2nd present term returned
print(traits[2,])

```

## Citation

To cite the ‘rfutres’ R package in publications
use:

``` 
   'Meghan Balk, John Deck, Neeka Sewnath,Robert Guralnick' (2021). rfutres: An interface to the Functional Trait Resource for Environmental Studies and associated data store.  R package version 1.0
   https://github.com/rfutres/rfutres
```

## Code of Conduct

View our [code of conduct](https://github.com/futres/rfutres/blob/master/CONDUCT.md)
