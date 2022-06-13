```r
setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)
source(maha.R) #in "R" folder
require(ggplot2)
require(dplyr)

cougar <- futres_data(scientificName = "Puma concolor")

cougar.df <- cougar$data

wildcat = cougar.df[cougar.df$scientificName == "Puma concolor",]

unique(wildcat$measurementType)
nrow(wildcat[wildcat$measurementType == "body mass",])

wildcat.flag <- outlier.flag(data = wildcat,
                             trait = "body mass")
unique(wildcat.flag$measurementStatus[wildcat$measurementType == "body mass"])
```
