---
title: "rppo vignette"
author: "John Deck"
date: "2018-05-16"
output:
 html_document:
    keep_md: yes
vignette: |
  %\VignetteIndexEntry{rppo Vignette} 
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}
---



The rppo package contains just two functions.  One to query terms from the PPO and another to query the data.  Following are three examples: the first two illustrate each of the functions and the third example illustrates how to use the functions together.

### ppo_terms function
It is frequently useful to look through the list of present and absent terms contained in the PPO.   The `ppo_terms` function returns present terms, absent terms, or both, returning a termID, label, definition and full URI for each term.  Use the termIDs returned from this function to query terms in the `ppo_data` function.  The following example returns the present terms into a "present_terms" data frame and a sample slice from the dataframe.


```r
present_terms <- ppo_terms(present = TRUE)
# print the first five rows, with just the termIDs and labels
print(present_terms[1:5,c("termID","label")])
#>            termID                                              label
#> 1 obo:PPO_0002300                           plant structures present
#> 2 obo:PPO_0002301                           new shoot system present
#> 3 obo:PPO_0002302 new above-ground shoot-borne shoot systems present
#> 4 obo:PPO_0002311                         breaking leaf buds present
#> 5 obo:PPO_0002303     new shoot systems emerging from ground present
```

### ppo_data function
The `ppo_data` function queries the PPO Data Portal, passing values to the database and extracting matching results. The results of the `ppo_data` function are returned as a list with four elements: 1) a data frame containing data, 2) a readme string containing usage information and some statistics about the query itself, 3) a citation string containing information about proper citation, 4) a number_possible integer indicating the total number of results if a limit has been specified, and 4) a status code returned from the service. The "df" variable below is populated with results from the data element in the results list, with an example
slice of data showing the first record.


```r
results <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110, termID = 'obo:PPO_0002313', limit = 10)
df <- results$data
print(df[1:1,])
#>   dayOfYear year   genus specificEpithet latitude longitude
#> 1       106 2013 Quercus          lobata 34.67545 -120.0407
#>                                                                                                                                                                                                                                            termID
#> 1 obo:PPO_0002316,obo:PPO_0002322,obo:PPO_0002018,obo:PPO_0002318,obo:PPO_0002022,obo:PPO_0002312,obo:PPO_0002313,obo:PPO_0002014,obo:PPO_0002024,obo:PPO_0002015,obo:PPO_0002000,obo:PPO_0002017,obo:PPO_0002020,obo:PPO_0002320,obo:PPO_0002315
#>    source                               eventId
#> 1 USA-NPN http://n2t.net/ark:/21547/Amg22054478
```

The readme and citation files returned by the list of results can be accessed by calling the readme and citation elements.  Note that the the file "citation_and_data_use_policies.txt" that is referred to in the readme file can be accessed using `cat(results$citation)` 

```r
cat(results$readme)
#> The following contains information about your download from the Global Plant 
#> Phenology Database.  Please refer to the citation_and_data_use_policies.txt 
#> file for important information about data usage policies, licensing, and 
#> citation protocols for each dataset.  This file contains summary information 
#> about the query that was run.  
#> 
#> data file = data.csv
#> date query ran = Wed May 16 2018 09:03:04 GMT-0400 (EDT)
#> query = +genus:Quercus AND +plantStructurePresenceTypes:"http://purl.obolibrary.org/obo/PPO_0002313" AND +year:>=2013 AND +year:<=2013 AND +dayOfYear:>=100 AND +dayOfYear:<=110 AND source:USA-NPN,NEON
#> fields returned = dayOfYear,year,genus,specificEpithet,latitude,longitude,source,eventId
#> user specified limit = 10
#> total results possible = 518
#> total results returned = 0
```

The results lists also shows the number of possible results in the results set, which is useful if the submitted query had a limit.  For example, in the query above, the limit is set to 10 but we want to know how many records were possible if the limit was not set.

```r
cat(results$number_possible)
#> 518
```

### working with terms and data together
Here we will generate a data frame showing the frequency of "present" and "absent" terms for a particular query.  The query is for genus = "Quercus" and latitude > 47.  For each row in the returned data frame `ppo_data` will typically return multiple terms in the termID field, corresponding to phenological stages as defined by the PPO.  For our example, we will generate a frequency table of the number of times "present" or "absent" term occur in the entire returned dataset.  Note that the termID field returned by `ppo_data` will return "presence" terms in addition to "present" and "absent" terms, while the `ppo_terms` function only returns "present" and "absent" terms.  Thus, our frequency distribution only counts the number of "present" and "absent" terms.  For an in-depth discussion of the difference between "presence" and "present", visit https://www.frontiersin.org/articles/10.3389/fpls.2018.00517/full.  Finally, since termIDs are returned as URI identifiers and not easily readable text, this example maps termIDs to labels. The resulting data frame shows two columns: 1) a column of term labels, and 2) a frequency of the number of times this label appeared in the result set. 


```r
###############################################################################
# Generate a frequency data frame showing the number of times each termID
# is populated for genus equals "Quercus" above latitude of 47
# Note that all latitude/longitude queries need to be in the format of a
# bounding box
###############################################################################
df <- ppo_data(
  genus = "Quercus", 
  bbox="47,-180,90,180")
#> sending request for data ...
#> https://www.plantphenology.org/api/v2/download/?q=%2Bgenus:Quercus+AND+%2Blatitude:>=47+AND+%2Blatitude:<=90+AND+%2Blongitude:>=-180+AND+%2Blongitude:<=180+AND+source:USA-NPN,NEON&source=latitude,longitude,year,dayOfYear,termID
# return just the termID column
t1 <- df$data[,c('termID')]
# paste each cell into one string
t2<-paste(t1, collapse = ",")
# split strings at ,
t3<-strsplit(t2, ",")
# create a frequency table as a data frame
freqFrame <- as.data.frame(table(t3))

# create a new data frame that we want to populate
resultFrame <- data.frame(
  label = character(), 
  frequency = integer(), 
  stringsAsFactors = FALSE)

###############################################################################
# Replace termIDs with labels in frequency frame
###############################################################################
# fetch "present" and "absent" terms using `ppo_terms`
termList <- ppo_terms(absent = TRUE, present = TRUE);
#> sending request for terms ...

# loop all "present"" and "absent" terms
for (term in 1:nrow(termList)) {
  termListTermID<-termList[term,'termID'];
  termListLabel<-termList[term,'label'];
  # loop all rows that have a frequency generated
  for (row in 1:nrow(freqFrame)) {
    freqFrameTermID = freqFrame[row,'t3']
    freqFrameFrequency = freqFrame[row,'Freq']
    # Populate resultFrame with matching "present" or "absent" labels.
    # In this step, we will ignore "presence" terms
    # found in the frequency frame since the ppo_terms only returns
    # "present" and "absent" terms. 
    if (freqFrameTermID == termListTermID) {
      resultFrame[nrow(resultFrame)+1,] <- c(termListLabel,freqFrameFrequency)
    }
  }
}

# print results, showing term labels and a frequency count
print(resultFrame)
#>                                                 label frequency
#> 1                            new shoot system present        32
#> 2  new above-ground shoot-borne shoot systems present        32
#> 3                          breaking leaf buds present        32
#> 4                                   leaf buds present        32
#> 5                       non-dormant leaf buds present        32
#> 6                             vascular leaves present       101
#> 7                                 true leaves present       101
#> 8                        unfolded true leaves present        69
#> 9          non-senescing unfolded true leaves present        22
#> 10              immature unfolded true leaves present        22
#> 11             expanding unfolded true leaves present        22
#> 12                      senescing true leaves present         6
#> 13                      expanding true leaves present        54
#> 14                      unfolding true leaves present        32
#> 15                    reproductive structures present        28
#> 16                          floral structures present        16
#> 17             non-senesced floral structures present         9
#> 18                                    flowers present         7
#> 19                       non-senesced flowers present         7
#> 20                               open flowers present         7
#> 21                   pollen-releasing flowers present         4
#> 22                                     fruits present        12
#> 23                            ripening fruits present        12
#> 24                            abscised leaves present         4
#> 25                          breaking leaf buds absent       159
#> 26                       senescing true leaves absent       342
#> 27                        unfolded true leaves absent       159
#> 28                          mature true leaves absent       159
#> 29          non-senescing unfolded true leaves absent       159
#> 30              expanding unfolded true leaves absent       159
#> 31               immature unfolded true leaves absent       159
#> 32               expanded immature true leaves absent       159
#> 33                  unopened floral structures absent       175
#> 34              non-senesced floral structures absent       175
#> 35          pollen-releasing floral structures absent       533
#> 36                      open floral structures absent       175
#> 37                    pollen-releasing flowers absent       358
#> 38                                open flowers absent       181
#> 39               pollen-releasing flower heads absent       358
#> 40                           open flower heads absent       181
#> 41                               unripe fruits absent       176
#> 42                             ripening fruits absent       176
#> 43                                 ripe fruits absent       362
#> 44                             abscised leaves absent       365
#> 45                    abscised fruits or seeds absent       365
#> 46                     abscised cones or seeds absent       365
```
