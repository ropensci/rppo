---
title: "rppo Vignette"
author: "John Deck"
date: "2018-05-08"
output:
   html_document:
    keep_md: yes
output.dir: inst/doc
vignette: |
  %\VignetteIndexEntry{rppo Vignette} 
  %\VignetteEngine{knitr::knitr}           
  %\VignetteEncoding{UTF-8}
---



The rppo package contains just two functions.  One to query terms from the PPO and another to query the data.  Following are examples in how to use these functions.

### ppo_terms function
A critical element of querying the PPO Data Portal is understanding the present and absent value terms contained in the PPO.   The ppo_terms function returns present terms, absent terms, or both, returning a termID, label, definition and full URI for each term.  Use the termIDs returned from this function to query terms in the ppo_data function.  The following example returns the present terms into a "present_terms" data frame.


```r
present_terms <- ppo_terms(present=TRUE)
#> [1] "sending request for terms ..."
```

### ppo_data function
The ppo_data function queries the PPO Data Portal, passing values to the database and extracting matching results. The results of the ppo_data function are returned as a lis with three elements: 1) a data frame containing data, 2) a readme string containing usage information and some statistics about the query itself, and 3) a citation string containing information about proper citation. The "df" variable below is populated with results from the data element in the results list.


```r
results <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110,termID='obo:PPO_0002313', limit=10)
#> [1] "sending request for data ..."
df <- results$data
print(df)
#>    dayOfYear year   genus specificEpithet latitude  longitude  source
#> 1        106 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 2        106 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 3        100 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 4        100 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 5        107 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 6        101 2013 Quercus          lobata 34.17370 -118.72417 USA-NPN
#> 7        108 2013 Quercus            alba 40.86668  -73.87873 USA-NPN
#> 8        108 2013 Quercus      imbricaria 40.86668  -73.87873 USA-NPN
#> 9        104 2013 Quercus       agrifolia 37.21306 -121.88297 USA-NPN
#> 10       100 2013 Quercus          lobata 37.21306 -121.88297 USA-NPN
#>                                  eventId
#> 1  http://n2t.net/ark:/21547/Amg22054478
#> 2  http://n2t.net/ark:/21547/Amg22054500
#> 3  http://n2t.net/ark:/21547/Amg22057612
#> 4  http://n2t.net/ark:/21547/Amg22057645
#> 5  http://n2t.net/ark:/21547/Amg22058125
#> 6  http://n2t.net/ark:/21547/Amg22048008
#> 7  http://n2t.net/ark:/21547/Amg23301759
#> 8  http://n2t.net/ark:/21547/Amg23301789
#> 9  http://n2t.net/ark:/21547/Amg22095132
#> 10 http://n2t.net/ark:/21547/Amg22213378
```

The readme string can be accessed by calling the readme list element.  An example of this is shown here:

```r
cat(results$readme)
#> The following contains information about your download from the Global Plant 
#> Phenology Database.  Please refer to the citation_and_data_use_policies.txt 
#> file for important information about data usage policies, licensing, and 
#> citation protocols for each dataset.  This file contains summary information 
#> about the query that was run.  
#> 
#> data file = data.csv
#> date query ran = Tue May 08 2018 17:56:22 GMT-0400 (EDT)
#> query = +genus:Quercus AND +plantStructurePresenceTypes:"http://purl.obolibrary.org/obo/PPO_0002313" AND +year:>=2013 AND +year:<=2013 AND +dayOfYear:>=100 AND +dayOfYear:<=110 AND source:USA-NPN,NEON
#> fields returned = dayOfYear,year,genus,specificEpithet,latitude,longitude,source,eventId
#> user specified limit = 10
#> total results possible = 518
#> total results returned = 10
```

The citation string can be accessed by calling the citation list element.  An example of this is shown here:

```r
cat(results$citation)
#> The Global PPO data store contains data from member networks.
#> Please refer to the following data usage and citation policies for each data source when using this data in your research.
#> Also note that in the examples of below, the dates mentioned in the citations are the most recent date of data harvest by the PPO data portal from each source and should be referenced in the citation and NOT the date downloaded by the user of the PPO data portal.
#> 
#> # PEP725 
#> # The Pan European Phenology Project
#> Date of Last Refresh: 2017-04-04
#> Data Policy: http://www.pep725.eu/downloads/PEP725_DataUsePolicy_201304.pdf
#> License: (see data policy statement)
#> Citation: PEP725 Pan European Phenology Data. Data set accessed 2017-04-04 at http://www.pep725.eu
#> 
#> # USA-NPN
#> # USA National Phenology Network
#> Date of Last Refresh: 2018-04-08
#> Data Policy:  https://www.usanpn.org/terms#DataUse
#> License: CC BY 4.0 https://creativecommons.org/licenses/by/4.0/legalcode
#> Metadata: https://data.usanpn.org:3002/pop/fgdc 
#> Citation: USA National Phenology Network. [Year of dataset access]. Plant and Animal Phenology Data. Data type: Status and Intensity. [Date range of data used] for Region: [Coordinates]. USA-NPN, Tucson, Arizona, USA. Data set accessed [Date] at http://doi.org/10.5066/F78S4N1V
#> Other Attribution: The acknowledgment “Data were provided by the USA National Phenology Network and the many participants who contribute to its Nature’s Notebook program.” must be included either in the main text or Acknowledgments section of all publications.
#> 
#> # NEON
#> # National Ecological Observatory Network
#> Date of Last Refresh: 2018-04-08
#> Metadata: http://data.neonscience.org/data-policy
#> Citation: National Ecological Observatory Network. 2016. Data Product NEON.DP1.10055.  Provisional data downloaded from http://data.neonscience.org April 8, 2018. Battelle, Boulder, CO, USA
```
