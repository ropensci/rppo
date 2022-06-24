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

##outlier detection
wildcat = cougar.df[cougar.df$scientificName == "Puma concolor",]

wildcat.flag <- outlier.flag(data = wildcat,
                             trait = "body mass")
nrow(wildcat[wildcat$measurementType == "body mass",]) #should have good values and maybe some "outliers"
unique(wildcat.flag$measurementStatus[wildcat.flag$measurementType == "body mass"])

wildcat.flag.adults <- outlier.flag(data = wildcat,
                                    trait = "body mass",
                                    stage = "adult")
nrow(wildcat[wildcat$measurementType == "body mass" &
             wildcat$lifeStage == "adult",]) #should be "too few records"
unique(wildcat.flag.adults$measurementStatus[wildcat.flag.adults$measurementType == "body mass"])

##normality test & flag outliers
wildcat.norm <- normal.flag(data = wildcat, 
                            trait = "body mass", 
                            sigma = 3)

unique(wildcat.norm$normality)

wildcat.trim <- wildcat[wildcat$measurementValue > 4000 &
                        wildcat$measurementValue < 10000,]

wildcat.norm <- normal.flag(data = wildcat.trim,
                            trait = "body mass",
                            sigma = 3)

unique(wildcat.norm$normality)
unique(wildcat.norm$measurementStatus)

##quantiles test & flag outliers

wildcat.quant <- quant.flag(data = wildcat, 
                            trait = "body mass")
unique(wildcat.quant$measurementStatus)```
