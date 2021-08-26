normal.data <- function(
  data,
  stage,
  age,
  )
  {
 
sp <- unique(data$scientificName)
data$normality <- ""
method <- c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value")
status <- c("outlier", "too few records")

data$logMeasurementValue <- log10(data$measurementValue)
data[!is.finite(data$logMeasurementValue),] <- NA

for(i in 1:length(sp.transform)){
   sub <- subset(data, subset = data$scientificName == sp[i] &
                                !(data$measurementStatus %in% status) &
                                 data$lifeStage == "adult" |
                                 data$ageValue >= age &
                                 !(data$measurementMethod %in% method &
                                 data$normality == "non-normal"))
  
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
                                         
  sub <- sub %>%
    drop_na(measurementValue)
   
  if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < 3)){
    data$normality[data$scientificName == sp.transform[i] & 
                   data$measurementType == trait & 
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == age |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method) &
                   data$normality == "non-normal"] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == "{body length}"]) > 5000)){
    x <- sample(sub$measurementValue[sub$measurementType == "{body length}"], 
                5000, replace = FALSE, prob = NULL)
    normal.body.mass <- shapiro.test(x)
    if(isTRUE(log.normal.mass[[2]] > 0.05)){
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "log normal"
    }
    else if(isTRUE(log.normal.mass[[2]] <= 0.05)){
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "non-normal (even logged)"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 & 
                 length(sub$measurementValue[sub$measurementType == trait]) >= 3)){
    log.normal.mass <- shapiro.test(sub$logMeasurementValue[sub$measurementType == trait])
    if(isTRUE(log.normal.mass[[2]] > 0.05)){
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "log normal"
    }
    else if(isTRUE(log.normal.mass[[2]] <= 0.05)){
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "non-normal (even logged)"
    }
  }
  else{
    next
  }
}
return(data)
}
