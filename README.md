# rppo
[![Build Status](https://travis-ci.org/biocodellc/rppo.svg?branch=master)](https://travis-ci.org/biocodellc/rppo)

R package for accessing PPO data store

# First time, installation:
```
install.packages("devtools")
library("devtools")
install_github("biocodellc/rppo")
```

# Thereafter, get started with the rppo library by specifying the library
```
library("rppo")
```

# A simple query to populate a data frame
```
df <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110)
```

# Point-mapping example using a data frame and leaflet
```
require("leaflet")        // may need to run install.packages('leaflet') on first time

# run a query to obtain some observations, the following should return around 4,000 records
df <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110)

# add the data to leaflet... NOTE: the following is to quickly visualize a small number (<10,000 records)
# adding more markers to a map than this could cause problems
map <- leaflet(df)
# addMarkers automatically looks at latitude/longitude column names from dataframe
map = addMarkers(map)
map = addProviderTiles(map, "Esri.NatGeoWorldMap")

```
