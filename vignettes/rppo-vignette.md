rppo Vignette
================
John Deck
2018-03-30

The rppo package contains just two functions. One to query terms from the PPO and another to query the data. Following are examples in how to use these functions.

### ppo\_terms function

A critical element of querying the PPO Data Portal is understanding the present and absent value terms contained in the PPO. The ppo\_terms function returns present terms, absent terms, or both, returning a termID, label, definition and full URI for each term. Use the termIDs returned from this function to query terms in the ppo\_data function. The following example returns the present terms into a "present\_terms" data frame.

``` r
present_terms <- ppo_terms(present=TRUE)
#> [1] "sending request for terms ..."
```

### ppo\_data function

The ppo\_data function queries the PPO Data Portal, passing values to the database and extracting matching results. The results of the ppo\_data function are returned as a lis with three elements: 1) a data frame containing data, 2) a readme string containing usage information and some statistics about the query itself, and 3) a citation string containing information about proper citation. The "df" variable below is populated with results from the data element in the results list.

``` r
results <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110,termID='obo:PPO_0002313', limit=10)
#> [1] "sending request for data ..."
df <- results$data
print(df)
#>    dayOfYear year   genus specificEpithet latitude  longitude  source
#> 1        104 2013 Quercus            alba 32.36376  -94.87395 USA-NPN
#> 2        107 2013 Quercus            alba 32.36376  -94.87395 USA-NPN
#> 3        105 2013 Quercus       palustris 37.19590  -80.40370 USA-NPN
#> 4        106 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 5        100 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 6        105 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 7        105 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 8        107 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 9        109 2013 Quercus          lobata 34.67545 -120.04069 USA-NPN
#> 10       108 2013 Quercus          lobata 34.15908 -118.72608 USA-NPN
#>                                  eventId
#> 1  http://n2t.net/ark:/21547/Amg22028446
#> 2  http://n2t.net/ark:/21547/Amg22052964
#> 3  http://n2t.net/ark:/21547/Amg22154999
#> 4  http://n2t.net/ark:/21547/Amg22054467
#> 5  http://n2t.net/ark:/21547/Amg22057612
#> 6  http://n2t.net/ark:/21547/Amg22058017
#> 7  http://n2t.net/ark:/21547/Amg22058028
#> 8  http://n2t.net/ark:/21547/Amg22058125
#> 9  http://n2t.net/ark:/21547/Amg22061984
#> 10 http://n2t.net/ark:/21547/Amg22085155
```

The readme string can be accessed by calling the readme list element. An example of this is shown here:

``` r
cat(results$readme)
#> The following contains information about your download from the Global Plant 
#> Phenology Database.  Please refer to the citation_and_data_use_policies.txt 
#> file for important information about data usage policies, licensing, and 
#> citation protocols for each dataset.  This file contains summary information 
#> about the query that was run.  
#> 
#> data file = data.csv
#> date query ran = Fri Mar 30 2018 20:57:39 GMT-0400 (EDT)
#> query = +genus:Quercus AND +plantStructurePresenceTypes:"http://purl.obolibrary.org/obo/PPO_0002313" AND +year:>=2013 AND +year:<=2013 AND +dayOfYear:>=100 AND +dayOfYear:<=110 AND source:USA-NPN,NEON
#> fields returned = latitude,longitude,year,dayOfYear,plantStructurePresenceTypes
#> user specified limit = 10
#> total results possible = 518
#> total results returned = 10
```

The citation string can be accessed by calling the citation list element. An example of this is shown here:

``` r
cat(results$citation)
#> The Global PPO data store contains data from member networks.
#> Please refer to the following data usage and citation policies for each data source when using this data in your research.
#> 
#> # PEP725 
#> # The Pan European Phenology Project
#> Data Policy: http://www.pep725.eu/downloads/PEP725_DataUsePolicy_201304.pdf
#> License: (see data policy statement)
#> Citation: PEP725 Pan European Phenology Data. Data set accessed YYYY-MM-DD at http://www.pep725.eu
#> 
#> # USA-NPN
#> # USA National Phenology Network
#> Data Policy: https://www.usanpn.org/terms
#> License: CC BY 4.0 https://creativecommons.org/licenses/by/4.0/legalcode
#> Citation: https://www.usanpn.org/terms
#> 
#> # NEON
#> # National Ecological Observatory Network
#> Data Policy: http://data.neonscience.org/data-policy
#> License: See http://data.neonscience.org/data-policy
#> Citation: See http://data.neonscience.org/data-policy
```
