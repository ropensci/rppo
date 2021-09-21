## test if logged data is normally distributed or not, and, if so, create upper and lower limits and label those outside of limits as possible outliers

# test for normality
normal.data <- function(
  data, #dataset to be added
  stage, #lifeStave to include
  age, #in lieu of lifeStage, age values to include
  n.limit = 3, # minimum number of samples wanted to test for normality; default is 3
  method = c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value"), #data we don't want to include in the test; can change it just showing the default
  status <- c("outlier", "too few records"), #data we don't want to include in the test
  sigma #value for how many standard deviations from the mean to calculate upper and lower limits
  )
  {
 
sp <- unique(data$scientificName)
  
#create column
  if(!isTRUE(data$normality)){
    data$normality <- ""
    }
  if(!isTRUE(data$sample.size)){
    data$sample.size <- ""
    }
  
data$logMeasurementValue <- log10(data$measurementValue) #creating logged values
data[!is.finite(data$logMeasurementValue),] <- NA #removing -Inf values

for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == stage |
                               data$ageValue >= age &
                               !(data$measurementMethod %in% method))
  
  sub$measurementValue <- as.numeric(sub$measurementValue) 
  sub <- sub[!is.na(sub$measurementValue),]
   
  data$sample.size[data$scientificName == sp[i] &
                   data$measurementType == trait &                   
                   data$lifeStage == stage |
                   !(data$measurementMethod %in% method &
                   !(data$measurementStatus %in% status) &
                   data$ageValue >= age] <- nrow(sub)
}
  
data$measurementStatus[data$sample.size < n.limit] <- "too few records" #identify which you won't be testing based on sample sizef

for(i in 1:length(sp.transform)){
  #create a subset of data of just the data we want to use to test normality, it will go species by species for the trait selected
   sub <- subset(data, subset = data$scientificName == sp[i] &
                                !(data$measurementStatus %in% status) &
                                 data$lifeStage == stage |
                                 data$ageValue >= age &
                                 !(data$measurementMethod %in% method))
  
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- sub[!is.na(sub$measurementValue),]
   
  if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < n.limit)){ #if it is less than the sample size limit, then flag as "too few records"
    data$normality[data$scientificName == sp.transform[i] & 
                   data$measurementType == trait & 
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == age |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method) &
                   data$normality == "non-normal"] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == "{body length}"]) > 5000)){ #if it is greater than 5000, then we need to subsample
    x <- sample(sub$measurementValue[sub$measurementType == "{body length}"], 
                5000, replace = FALSE, prob = NULL)
    normal.body.mass <- shapiro.test(x) # normality test
    if(isTRUE(log.normal.mass[[2]] > 0.05)){ #if not significantly different, then log normal
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "log normal"
    }
    else if(isTRUE(log.normal.mass[[2]] <= 0.05)){ #if significantly different, then non-normal
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "non-normal (even logged)"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 & #if between n.limit and 5000, then test for normality
                 length(sub$measurementValue[sub$measurementType == trait]) >= n.limit)){
    log.normal.mass <- shapiro.test(sub$logMeasurementValue[sub$measurementType == trait]) #normality test
    if(isTRUE(log.normal.mass[[2]] > 0.05)){ #if not significantly different, then log normal
      data$normality[data$scientificName == sp.transform[i] & 
                     data$measurementType == trait & 
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == age &|
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method) &
                     data$normality == "non-normal"] <- "log normal"
    }
    else if(isTRUE(log.normal.mass[[2]] <= 0.05)){ #if significantly different, non-normal
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

#create new columns if they don't currently exist
  if(!(isTRUE(data$upperLimit)){
    data$upperLimit <- ""
    data$lowerLimit <- ""
    data$upperLimitMethod <- ""
    data$lowerLimitMethod <- ""
  })
  if(!(isTRUE(data$meanValue)){
    data$meanValue <- ""
    data$sdValue <- ""
  })
       
for(i in 1:length(sp){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == stage |
                               data$ageValue >= age &
                               !(data$measurementMethod %in% method) &
                               data$normality = "non-normal (even logged)") #only for log normal data
  
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- sub[!is.na(sub$measurementValue),]
  
  data$meanValue[data$scientificName == sp[i] &
                 data$measurementType == trait] <- mean(sub$measurementValue) #get mean value for each species and each trait
  
  data$sdValue[data$scientificName == sp[i] &
               data$measurementType == trait] <- sd(sub$measurementValue) #get standard deviation for each species and each trait
                                                   
  data$upperLimit[data$scientificName == sp[i] &
                   data$measurementType == trait] <- mean(sub$measurementValue)+sigma*sd(sub$measurementValue) #calculate upper limit as mean + sigma*sd
  
  data$lowerLimit[data$scientificName == sp[i] &
                  data$measurementType == trait] <- mean(sub$measurementValue)-sigma*sd(sub$measurementValue) #calculate lower limit as mean = sigma*Sd
  
  data$lowerLimitMethod[data$scientificName == sp[i] &
                        data$measurementType == trait] <- "log sd, non-estimated values, no outliers" #label method
  
  data$upperLimitMethod[data$scientificName == sp[i] &
                        data$measurementType == trait] <- "log sd, non-estimated values, no outliers" #label method
}
                                                                                                                
for(i in 1:length(sp)){
  sub <- data[data$scientificName == sp[i] & 
              data$measurementType == trait &
              !(data$measurementStatus %in% status) &
              data$lowerLimitMethod == "log sd, non-estimated values, no outliers",] #only use for those that use the log method
  
  for(j in 1:nrow(sub)){
    if(isTRUE(sub$measurementValue[j] <= sub$lowerLimit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "juvenile.log.sd"
    }
    else if(isTRUE(sub$measurementValue[j] >= sub$upperLimit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "outlier.log.lsd"
    }
    else{
      data$measurementStatus[data$index == sub$index[j]] <- "possible adult, possibly good"
    }
  }
} 
                                                                                                                
return(data)
}
