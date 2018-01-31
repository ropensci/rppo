# ppo-r-interface
R package for accessing PPO data store


# Example of fetching GBIF data and mapping using leaflet
```
require("rgbif")
require("leaflet")

# Return search data as type data, this we can convert to data.frame
occ_data <- occ_search(scientificName = "Ursus americanus", limit = 50, return=data)

# rename column names so the addMarkers can automatically infer lat/lng columns
colnames(occ_data)[which(names(occ_data) == "decimalLatitude")] <- "latitude"
colnames(occ_data)[which(names(occ_data) == "decimalLongitude")] <- "longitude"

# create a fresh data frame
occ_frame <- as.data.frame(occ_data)

map <- leaflet(occ_frame)
map = addMarkers(map)
map = addProviderTiles(map, "Esri.NatGeoWorldMap")
```
