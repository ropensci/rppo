# Place

```r
deer.country <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", country = "United States")

ggplot(deer.country) +
geom_density(aes(x = measurementType == "mass", fill = "state"))

deer.states <- deer.country %>%
group_by(state)

```

# Time

```r
deer.recent <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", fromYear = 2000, toYear = 2021)

ggplot(deer.recent) +
geom_density(aes(x = measurementType == "mass", fill = "sex"))

deer.old <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus", culturalPeriod = "Mayan")

ggplot(deer.old) +
geom_density(aes(x = measurementType == "mass", fill = "state"))

```

# Between Species

```r
artiodactyla <- futres_data(order = "Artiodactlidae")

ggplot(artiodactyla) +
geom_density(aes(x = measurementType == "mass", fill = "binomial"))

```

# Across Traits

```r
deer <- futres_data(genus = "Odocoileus", specificEpithet = "virginianus")

ggplot(deer) +
geom_smooth(aes(x = measurementType == "total length", y = measurementType == "mass") +
geom_point(aes(measurementType == "total length", measurementType == "mass")

```
