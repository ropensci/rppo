# rFuTRES tutorial

The futres_data function returns a list containing the following information: a readme file, citation information, a data frame with data, an integer with the number of records returned and status code. The function is called with parameters that correspond to values contained in the data itself which act as a filter on the returned record set.

Below are examples of querying data with different filters in order to return a record set appropriate for various research questions. 

Be sure to load the following libaries:
ggplot
dplyr

## Place

The 'country' argument allows users to specify record sets from specific countries. 

```r
deer <- futres_data(scientificName = "Odocoileus virginianus")
deer.df <- deer$data
unique(deer.df$country)
deer.usa <- deer.df[deer.df$country == "USA",]

ggplot(deer.usa) +
  geom_density(aes(x = measurementType == "body mass", fill = "locality"))

deer.locality <- deer.usa %>%
group_by(locality)

```

## Time

The 'fromYear' and 'toYear' arguments allow users to specify a custom time range when curating a record set. 

```r
deer.recent <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", fromYear = 2000, toYear = 2021)

deer.recent.df <- deer.recent$data

ggplot(deer.recent.df) +
geom_density(aes(x = measurementType == "body mass", fill = "sex"))
```

## Between Species

Here we investigate a singular trait amomgst multuple species in an order.  

```r
squirrel <- futres_data(genus = "Otospermophilus")
squirrel.df <- squirrel$data
unique(squirrel.df$scientificName)

ggplot(squirrel.df) +
  geom_density(aes(x = measurementType == "body mass", fill = "scientificName"))
```

## Across Traits

Here we demonstrate a means of exploring trait relationships within a custom record set using futres_data().

```r
deer <- futres_data(scientificName = "Odocoileus virginianus")
deer.df <- deer$data

ggplot(deer.df) +
geom_smooth(aes(x = measurementType == "total length", y = measurementType == "body mass")) +
geom_point(aes(measurementType == "total length", measurementType == "body mass"))
```

