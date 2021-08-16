# rFuTRES tutorial

The futres_data function returns a list containing the following information: a readme file, citation information, a data frame with data, an integer with the number of records returned and status code. The function is called with parameters that correspond to values contained in the data itself which act as a filter on the returned record set.

Below are examples of querying data with different filters in order to return a record set appropriate for various research questions. 

## Place

The 'country' argument allows users to specify record sets from specific countries. 

```r
deer.country <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", country = "United States")

ggplot(deer.country) +
geom_density(aes(x = measurementType == "mass", fill = "state"))

deer.states <- deer.country %>%
group_by(state)

```

## Time

The 'fromYear' and 'toYear' arguments allow users to specify a custom time range when curating a record set. 

```r
deer.recent <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", fromYear = 2000, toYear = 2021)

ggplot(deer.recent) +
geom_density(aes(x = measurementType == "mass", fill = "sex"))

deer.old <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", culturalPeriod = "Mayan")

ggplot(deer.old) +
geom_density(aes(x = measurementType == "mass", fill = "state"))

```

## Between Species

Here we investigate a singular trait amomgst multuple species in an order.  

```r
artiodactyla <- futres_data(order = "Artiodactlidae")

ggplot(artiodactyla) +
geom_density(aes(x = measurementType == "mass", fill = "binomial"))

```

## Across Traits

Here we demonstrate a means of exploring trait relationships within a custom record set using futres_data().

```r
deer <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus")

ggplot(deer) +
geom_smooth(aes(x = measurementType == "total length", y = measurementType == "mass") +
geom_point(aes(measurementType == "total length", measurementType == "mass")

```

