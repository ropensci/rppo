```
#setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)

#get data
x <- futres_data(scientificName = "Puma concolor")
cougar <- x$data

## to see all the traits in FOVT (FuTRES Ontology or Vertebrate Traits)
traits <- futres_traits()
traits$label

## extract only body size 
cougar.bs <- cougar.df[cougar.df$measurementType == "body mass",]

## extract range of values
range(cougar.bs$measurementValue)
```
