
# Example extracting taxa from FuTRES

## Specific species

```r
#get 10 records of Puma concolor
mtnLion <- futres_data(genus = "Puma", specificEpithet = "concolor", limit=10)
```

## Higher taxonomic levels

puma <- futres_data(genus = "Puma", limit=10)
