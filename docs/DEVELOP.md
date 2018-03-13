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
// Following line,  FIRST TIME ONLY
devtools::install_github("klutometis/roxygen")  // Install ROxygen for Document Building
library(roxygen2)     // Use the Oxygen library
document()            // Document the project
```
