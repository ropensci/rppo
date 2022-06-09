```r
#setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)

## extract data based off lat/log using bbox 
# bbox: west, south, east, north
NW.cougar <- futres_data(scientificName = "Puma concolor",
                         bbox = "42, -125, 46, -111")
NW.cougar.df <- NW.cougar$data
length(unique(NW.cougar.df$individualID)) #number of unique individuals in dataset
nrow(NW.cougar.df) #number may differ from number of individuals if there are multiple measurements per individual

## new data set to then extract lat and long, or locality
cougar.df <- cougar$data

## lat/long
range(cougar.df$decimalLatitude, na.rm = TRUE)
range(cougar.df$decimalLongitude, na.rm = TRUE)

## locality
unique(cougar.df$locality)
```
