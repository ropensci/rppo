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

# Point-mapping example using a data frame and leaflet
```
require("leaflet")

# Create a test data frame (this code to be replaced by a PPO function to return data frame)
id <- c('1','2','3')
latitude <- c(45, 46, 44)
longitude <- c(-121,-120,-122)
year <- c(2010, 2008, 2007)
sampleData <- data.frame(id, latitude, longitude, year)

# add the data to leaflet
map <- leaflet(sampleData)
# addMarkers automatically looks at latitude/longitude column names from dataframe
map = addMarkers(map)
map = addProviderTiles(map, "Esri.NatGeoWorldMap")

```
