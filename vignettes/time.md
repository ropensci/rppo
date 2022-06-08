```r
#setwd(".")
library("devtools")
# if you don't have devtools, you can install with install.packages("devtools" first
devtools::install_github("futres/rfutres")
library(rfutres)

## extract cougar (Puma concolor) data
cougar <- futres_data(scientificName = "Puma concolor")

cougar.df <- cougar$data

## extract data from a range
r <- futres_data(fromYear = 2000, toYear = 2010, limit=2)
data <- r$data

## extract yearCollected
cougar.df$yearCollected

## extract year collected range
range(cougar.df$yearCollected, na.rm = TRUE)

## extract lifeStage
unique(cougar.df$lifeStage)
cougar.df[cougar.df$lifeStage == "adult",]
```
