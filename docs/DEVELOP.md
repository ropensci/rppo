# Development Notes

# Install package (locally)
```
cd <git root>     // Change to root diretory
r                 // start up R
> library(devtools)
> setwd("..")
> library("rppo")
```

# Running the package from source (locally)
```
install.packages("R.utils")
library(R.utils)
sourceDirectory(".")  // Run the sourceDirectory command each time a change is made to source
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
