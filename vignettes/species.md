```r
#setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)

#get 10 records of Puma concolor
cougar <- futres_data(scientificName = "Puma concolor", limit = 10)

## higher taxnomic levels
puma <- futres_data(genus = "Puma", limit=10)

mtnLion <- futres_data(genus = "Puma", specificEpithet = "concolor", limit=10)
```
