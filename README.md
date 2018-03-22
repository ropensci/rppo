
<!-- README.md is generated from README.Rmd. Please edit that file -->
rppo
====

The global plant phenology data portal (PPO data portal) is an aggregation of plant phenological observations from [USA-NPN](https://www.usanpn.org/usa-national-phenology-network), [NEON](https://www.neonscience.org/), and [PEP725](http://www.pep725.eu/) representing 20 million phenological observations. The PPO data portal utilizes the [Plant Phenology Ontology](https://github.com/PlantPhenoOntology/ppo/) to align phenological terms and measurements from the various databases. The rppo R package enables programmatic access to all data contained in the PPO data portal.

For more information visit the [PPO global data portal](http://plantphenology.org/) or the [ppo-data-pipeline git repository](https://github.com/biocodellc/ppo-data-pipeline).

Installation
------------

You can install rppo from github with:

``` r
# install.packages("devtools")
devtools::install_github("biocodellc/rppo")
```

Example
-------

Query the plant phenology ontology and return a list of present or absent terms. Use the termIDs returned from this function to query terms in the ppo\_data function

``` r
library(rppo)
present_terms <- ppo_terms(present=T)
#> [1] "retrieving terms ..."
```

A simple query example to populate a data frame

``` r
df <- ppo_data(genus = "Quercus", fromYear = 2013, toYear = 2013, fromDay = 100, toDay = 110,termID='obo:PPO_0002313')
#> [1] "sending request to http://api.plantphenology.org/v1/download/?q=%2Bgenus:Quercus+AND+%2BplantStructurePresenceTypes:\"obo:PPO_0002313\"+AND+%2Byear:>=2013+AND+%2Byear:<=2013+AND+%2BdayOfYear:>=100+AND+%2BdayOfYear:<=110+AND+source:USA-NPN,NEON&source=latitude,longitude,year,dayOfYear,plantStructurePresenceTypes"
#> [1] "unzipping response and processing data"
```

Citation
--------

To cite package 'rppo' in publications use:

       'John Deck' (2018). rppo: An interface to the Plant Phenology Ontology and associated data store.  R package version 0.1
       https://github.com/biocodellc/rppo
