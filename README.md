
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rfutres

The Functional Trait Resource for Environmental Studies project, or [FuTRES](https://www.futres.org/), aggregates vertebrate traits from 
[Vertnet](http://vertnet.org/) and other research datasets.
The FuTRES project utilizes the [FuTRES Ontology for Vertebrate Traits](https://github.com/futres/fovt) (FOVT) to align
trait terms from the various databases. The rfutres
R package enables programmatic access to all data contained in the FuTRES
data portal incuding selected classes contained in the fovt ontology.

For information on how data is assembled for the FuTRES data portal, visit
the [fovt-data-pipeline git
repository](https://github.com/futres/fovt-data-pipeline).

## Installation

The production version of rfutres will soon be accessible on CRAN.  Until then, you can install the development version of rfutres from github with:

``` r
#if having issues, try setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)
```

## Examples

Following are a couple of brief examples to illustrate how to get
started with rfutres. We recommend visiting the futres man pages in the R environment, using
`?futres_data` and
`?futres_traits`.

``` r
# query all results from day 1 through 100 in a particular bounding box, 
# limited to 2 records
r <- futres_data(fromYear = 2000, toYear = 2010, limit=2)

# bounding box search
# lat, lng, lat, lng  (any two corners of box)
r <- futres_data(bbox="37,-120,38,-119", limit=2)

# view the data returned
print(r$data)

# view the number of possible records returned
print(r$number_possible)

# print the download citation
print(r$citation)

# print the download readme
print(r$readme)

# return a data frame of traits
traits <- futres_traits()

# print the 2nd present term returned
print(traits[2,])

# query all data from futres (try this only if you are willing to wait for the entire set to load)
r_all <- futres_data()

```

## Citation

To cite the ‘rfutres’ R package in publications
use:

``` 
   'Meghan Balk, John Deck, Neeka Sewnath, Robert Guralnick' (2021). rfutres: An interface to the Functional Trait Resource for Environmental Studies and associated data store.  R package version 1.0
   https://github.com/rfutres/rfutres
```

## Code of Conduct

View our [code of conduct](https://github.com/futres/rfutres/blob/master/CONDUCT.md)
