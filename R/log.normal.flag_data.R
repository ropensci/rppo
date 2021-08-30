normal.data <- function(
  data,
  stage,
  age,
  n.limit
  )
  {
 
sp <- unique(data$scientificName)
data$normality <- ""
method <- c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value")
status <- c("outlier", "too few records")
data$index <- rownames(data)
data$sample.size <- ""

data$logMeasurementValue <- log10(data$measurementValue)
data[!is.finite(data$logMeasurementValue),] <- NA

for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == "adult" |
                               !(data$measurementMethod %in% method &
                               data$ageValue >= age))
  
  sub$measurmeentValue <- as.numeric(sub$measurementValue) 
  sub <- !is.na(sub)
   
  data$sample.size[data$scientificName == sp[i] &
                   data$measurementType == trait &                   
                   data$lifeStage == "adult" |
                   !(data$measurementMethod %in% method &
                   !(data$measurementStatus %in% status) &
                   data$ageValue >= age] <- nrow(sub)
}
  
data$measurementStatus[data$sample.size < n.limit] <- "too few records"

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

data$upper.limit.log.norm <- ""
data$lower.limit.log.norm <- ""
data$log.mean <- ""
data$log.sigma <- ""
       
for(i in 1:length(sp){
  data$log.mean[data$scientificName == sp[i] &
                !(data$measurementStatus %in% status) &
                !(data$measurementMethod %in% method) &
                data$lifeStage == stage |
                data$ageValue == age &
                data$measurementType == trait)] <- mean(data$log.measurementValue[data$scientificName == sp[i] &
                                                                                  !(data$measurementStatus %in% status) &
                                                                                  !(data$measurementMethod %in% method) &
                                                                                  data$lifeStage == stage |
                                                                                  data$ageValue == age &
                                                                                  data$measurementType == trait)]
  data$log.sigma[data$scientificName == sp[i] &
                !(data$measurementStatus %in% status) &
                !(data$measurementMethod %in% method) &
                data$lifeStage == stage |
                data$ageValue == age &
                data$measurementType == trait)] <- sd(data$log.measurementValue[data$scientificName == sp[i] &
                                                                                !(data$measurementStatus %in% status) &
                                                                                !(data$measurementMethod %in% method) &
                                                                                data$lifeStage == stage |
                                                                                data$ageValue == age &
                                                                                data$measurementType == trait)]
                                                   
  data$upper.limit.log.norm[data$scientificName == sp[i] &
                            !(data$measurementStatus %in% status) &
                            !(data$measurementMethod %in% method) &
                            data$lifeStage == stage |
                            data$ageValue == age &
                            data$measurementType == trait)] <- data$log.mean[data$scientificName == sp[i] &
                                                                             !(data$measurementStatus %in% status) &
                                                                             !(data$measurementMethod %in% method) &
                                                                             data$lifeStage == stage |
                                                                             data$ageValue == age &
                                                                             data$measurementType == trait)] + (sigma*data$log.sigma[data$scientificName == sp[i] &
                                                                                                                                     !(data$measurementStatus %in% status) &
                                                                                                                                     !(data$measurementMethod %in% method) &
                                                                                                                                     data$lifeStage == stage |
                                                                                                                                     data$ageValue == age &
                                                                                                                                     data$measurementType == trait)]  
                                                                                                        
  data$lower.limit.log.norm[data$scientificName == sp[i] &
                            !(data$measurementStatus %in% status) &
                            !(data$measurementMethod %in% method) &
                            data$lifeStage == stage |
                            data$ageValue == age &
                            data$measurementType == trait)] <- data$log.mean[data$scientificName == sp[i] &
                                                                             !(data$measurementStatus %in% status) &
                                                                             !(data$measurementMethod %in% method) &
                                                                             data$lifeStage == stage |
                                                                             data$ageValue == age &
                                                                             data$measurementType == trait)] - (sigma*data$log.sigma[data$scientificName == sp[i] &
                                                                                                                                     !(data$measurementStatus %in% status) &
                                                                                                                                     !(data$measurementMethod %in% method) &
                                                                                                                                     data$lifeStage == stage |
                                                                                                                                     data$ageValue == age &
                                                                                                                                     data$measurementType == trait)]  
}
                                                                                                                
for(i in 1:length(sp.limits)){
  sub <- data[data$scientificName == sp[i] & 
              data$measurementType == trait &
              !(data$measurementStatus %in% status),]
  for(j in 1:nrow(sub)){
    if(isTRUE(sub$measurementValue[j] <= sub$lower.limit.log.norm[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "possibly not adult"
    }
    else if(isTRUE(sub$measurementValue[j] >= sub$upper.limit.log.mass[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "possibly outlier"
    }
    else{
      data$measurementStatus[data$index == sub$index[j]] <- "possibly adult"
    }
  }
} 
                                                                                                                
return(data)
}
