# Development Notes

Installing package from Source
```
cd <git root>     // Change to root diretory
r                 // start up R
> install.packages(".",repos=NULL, type="source")
> library("rppo")
```

Building Doccumentation
```
// Following line,  FIRST TIME ONLY
devtools::install_github("klutometis/roxygen")  // Install ROxygen for Document Building
library(roxygen2)     // Use the Oxygen library
document()            // Document the project
```
