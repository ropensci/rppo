```r
#setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)

## extract data based off lat/log using bbox 
# bbox: west, south, east, north
NW.cougar <- futres_data(scientificName = "Puma concolor",
                         bbox = c(125, 42, 111,46))

## extract locality
cougar <- futres_data(scientificName = "Puma concolor", bbox)

cougar.df <- cougar$data

## lat/long
range(cougar.df$decimalLatitude, na.rm = TRUE)
range(cougar.df$decimalLongitude, na.rm = TRUE)

## locality
unique(cougar.df$locality)
```
