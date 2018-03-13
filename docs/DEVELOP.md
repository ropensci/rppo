# Development Notes

# Running the package from source, useful in active development
```
install.packages("R.utils")
library(R.utils)
sourceDirectory(".")  // Run the sourceDirectory command each time a change is made to source
```

# Running the package from Source, useful to test the package itself before deployment
```
cd <git root>     // Change to root diretory
r                 // start up R
> install.packages(".",repos=NULL, type="source")
> library("rppo")
```

# Building Doccumentation
```
// Following lines,  FIRST TIME ONLY
devtools::install_github("klutometis/roxygen")  
install.packages('leafletR')
install.packages('rjson')
install.packages('devtools')
install.packages('plyr')
// Following lines, WHEN SETTING UP WORKSPACE
library(devtools)
library(roxygen2)     
library(rjson)
library(plyr)
library(leafletR)
// Following lines, WHEN ABOVE HAS BEEN SET
setwd(".")
document()            
```
