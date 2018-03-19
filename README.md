# rppo
[![Build Status](https://travis-ci.org/biocodellc/rppo.svg?branch=master)](https://travis-ci.org/biocodellc/rppo)

The following is an R package for accessing the plant phenology ontology (PPO) global data store. For more information visit 
the web portal at http://plantphenology.org/ or the github site for processing data at https://github.com/biocodellc/ppo-data-pipeline

# Installation
```
install.packages("devtools")
library("devtools")
install_github("biocodellc/rppo")
```

# Loading the library
```
library("rppo")
```

# Manual 
The rppo package has been documented using R manual entries.  To learn more about the package and functions in the
R environment, try the following commands after loading rppo library in the R environment.
```
?rppo               # man entry for the package itself
?ppo_get_terms      # man entry for the ppo_get_terms function
?ppo_get_data       # man entry for the ppo_get_data function
```

# Query the plant phenology ontology and return a list of present or absent stages
you can use the stageIDs returned from this function to query stages in the ppo_data function
```
presentStages <- get_ppo_terms(TRUE)
absentStages <- get_ppo_terms(FALSE)
```


# A simple query example to populate a data frame
```
df <- get_ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110,termID='obo:PPO_0002313')
```


# Point-mapping example using a data frame and leaflet
```
require("leaflet")        // may need to run install.packages('leaflet') on first time

# run a query to obtain observations
df <- get_ppo_data(bbox='44,-124,46,-122', fromDay = 1, toDay = 60)

# add the data to leaflet... NOTE: the following is to quickly visualize a small number (<10,000 records)
# adding more markers to a map than this could cause problems
map <- leaflet(df)
# addMarkers automatically looks at latitude/longitude column names from dataframe
map = addMarkers(map)
map = addProviderTiles(map, "Esri.NatGeoWorldMap")

```
