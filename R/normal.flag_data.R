## test if data is normally distributed or not, and if so, create upper and lower limits and label those outside of limits as possible outliers

#test for normality
normal.flag <- function(
    data, #dataset to be added
    stage = NULL, #lifeStage to include
    sigma, #value for how many standard deviations from the mean to calculate upper and lower limits
    sample.min = NULL, #minimum number of samples wanted to test for normality (e.g., must be greater than 3); default is 3
    #sample.min is also for the number of unique records
    #method = c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value"), #data we don't want to include in the test; can change it just showing the default
    taxa = NULL, #by default does all the species in the dataset
    status = c("outlier", "too few records"), #data we don't want to include in the test; assumes you've already done the "outlier.flag()"
    trait #trait of interest
)
{
  
  #create column to label normality results
  if(!isTRUE(colnames(data) %in% "normality")){
    data[,"normality"] <- ""
  }
  
  #create column to record sample size
  if(!isTRUE(colnames(data) %in% "sample.size")){
    data[, "sample.size"] <- ""
  }
  
  #create column for measurementStatus if it does not already exist
  if(!isTRUE(colnames(data) %in% "measurementStatus")){
    data[, "measurementStatus"] <- ""
  }
  
  data[, "measurementValue"] <- as.numeric(data[, "measurementValue"])

  #create index of species names to go through
  #by default goes through all species in the dataset
  if(isTRUE(is.null(taxa))){
    sp <- unique(data[,"scientificName"])
  }
  else{
    sp <- taxa
  }
  
  if(isTRUE(is.null(sample.min))){
    n.limit = 3
  }
  else{
    n.limit = sample.min
  }
  
  data[,"index"] <- rownames(data)
  
  for(i in 1:length(sp)){
    #create a dataframe of just the measurements of the select trait for a species
    sub <- subset(data, subset = data[, "scientificName"] == sp[i] &
                                 data[, "measurementType"] == trait &
                                 !(data[, "measurementStatus"] %in% status))
    
    #if they have lifeStage not null, trim the dataset more
      if(!isTRUE(is.null(stage))){
        sub <- subset(sub, subset = sub[, "lifeStage"] == stage)
      }
    
    #make numeric
    sub[, "measurementValue"] <- as.numeric(sub[, "measurementValue"]) 
    
    #remove NAs from measurementValue
    sub <- sub[!is.na("measurementValue"),]

    #calculate sample size for records being included in normality test
    data$sample.size[data$scientificName == sp[i] &
                     data$measurementType == trait] <- as.numeric(nrow(sub))

    if(isTRUE(sub$sample.size < n.limit)){
    data$measurementStatus[data$scientificName == sp[i] &
                           data$measurementType == trait] <- "too few records" #identify which species you don't want to include because they don't have enough samples
      next
    }
  
    else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < n.limit |
            length(unique(sub$measurementValue[sub$measurementType == trait])) < n.limit)){ #if it is less than the sample size limit, then flag as "too few records"
      data$measurementStatus[data$scientificName == sp[i] & 
                           data$measurementType == trait] <- "too few records"
      next
    }
  ##testing if has more than 5K records, the test won't work
  ##if it is greater than 5000, then we need to subsample
    else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) > 5000)){ 
      x <- sample(sub$measurementValue[sub$measurementType == trait], 
                  5000, replace = FALSE, prob = NULL)
      normal <- shapiro.test(x) #normality test
      if(isTRUE(normal[[2]] < 0.05)){ #if significantly different, then non-normal
        data$normality[data$measurementType == trait & 
                       data$scientificName == sp[i] &
                       !(data[, "measurementStatus"] %in% status)] <- "non-normal"
      }
      else if(isTRUE(normal[[2]] >= 0.05)){ #if not significantly different, then non-normal
        data$normality[data$measurementType == trait & 
                       data$scientificName == sp[i] &
                       !(data[, "measurementStatus"] %in% status)] <- "normal"
      }
    }
  ##now testing if less than 5K and more than then minimum sample size needed
    else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 &
                   length(sub$measurementValue[sub$measurementType == trait]) >= n.limit & 
                   length(unique(sub$measurementValue[sub$measurementType == trait])) >= n.limit)){
      normal.trait <- shapiro.test(sub$measurementValue[sub$measurementType == trait]) #normality test
      if(isTRUE(normal.trait[[2]] < 0.05)){ #if significantly different, then not normal
        data$normality[data$scientificName == sp[i] &
                       data$measurementType == trait & 
                       !(data[, "measurementStatus"] %in% status)] <- "non-normal"
      }
      else if(isTRUE(normal.trait[[2]] >= 0.05)){ #if not significantly different, then normal
        data$normality[data$scientificName == sp[i] &
                     data$measurementType == trait & 
                     !(data[, "measurementStatus"] %in% status)] <- "normal"
      }
    }
    else{
      next
    }
  }
  
#create new columns if they don't currently exist
##if don't have one of these columns, likely don't have any
  if(!(isTRUE(colnames(data) %in% "upperLimit"))){
    data[,"upperLimit"] <- ""
    data[,"lowerLimit"] <- ""
    data[,"limitMethod"] <- ""
  }
##if don't have one of these columns, likely don't have any
  if(!(isTRUE(colnames(data) %in% "meanValue"))){
     data[,"meanValue"] <- ""
     data[,"sdValue"] <- ""
  }

##need to create new subset for creating means and limits for normal traits only to label outliers
  for(i in 1:length(sp)){
    #create a dataframe of just the measurements of the select trait for a species
    sub <- subset(data, subset = data[, "scientificName"] == sp[i] &
                                 data[, "measurementType"] == trait &
                                 !(data[, "measurementStatus"] %in% status) &
                                 data[, "normality"] != "non-normal")
  
    #if they have lifeStage not null, trim the dataset more
    if(!isTRUE(is.null(stage))){
      sub <- subset(sub, subset = sub[, "lifeStage"] == stage)
    }
  
    #make numeric
    sub[, "measurementValue"] <- as.numeric(sub[, "measurementValue"]) 
  
    #remove NAs from measurementValue
    sub <- sub[!is.na("measurementValue"),]
  
    ##calculate mean
    data$meanValue[data$scientificName == sp[i] &
                   data[, "measurementType"] == trait &
                   !(data[, "measurementStatus"] %in% status) &
                   data[, "normality"] != "non-normal"] <- mean(sub$measurementValue) #get mean value for each species and each trait
  
    ##calculate standard deviation 
    data$sdValue[data$scientificName == sp[i] &
                 data[, "measurementType"] == trait &
                 !(data[, "measurementStatus"] %in% status) &
                 data[, "normality"] != "non-normal"] <- sd(sub$measurementValue) #get standard deviation for each species and each trait
  
    ##calculate upper limit
    data$upperLimit[data[, "scientificName"] == sp[i] &
                   data[, "measurementType"] == trait &
                   !(data[, "measurementStatus"] %in% status) &
                   data[, "normality"] != "non-normal"] <- mean(sub$measurementValue) + sigma*sd(sub$measurementValue) #calculate upper limit as mean + sigma*sd
  
    ##calculate lower limit
    data$lowerLimit[data[, "scientificName"] == sp[i] &
                    data[, "measurementType"] == trait &
                   !(data[, "measurementStatus"] %in% status) &
                   data[, "normality"] != "non-normal"] <- mean(sub$measurementValue) - sigma*sd(sub$measurementValue) #calculate lower limit as mean - sigma*sd
  
    ##label method
    data$limitMethod[data[, "scientificName"] == sp[i] &
                     data[, "measurementType"] == trait &
                     !(data[, "measurementStatus"] %in% status) &
                     data[, "normality"] != "non-normal"] <- "sd"
  
  }
#create new dataset to label the measurementStatus now accounting for method
  for(i in 1:length(sp)){
    #create a dataframe of just the measurements of the select trait for a species
    sub <- subset(data, subset = data[, "scientificName"] == sp[i] &
                                 data[, "measurementType"] == trait &
                                 data$limitMethod == "sd")
  
    #if they have lifeStage not null, trim the dataset more
    if(!isTRUE(is.null(stage))){
      sub <- subset(sub, subset = sub[, "lifeStage"] == stage)
    }
    
    sub[, "upperLimit"] <- as.numeric(sub[, "upperLimit"])
    sub[, "lowerLimit"] <- as.numeric(sub[, "lowerLimit"])
  
  ##label "juvenile" if lower than the lower limit
  ##label "outlier" if greater than the upper limit
  ##label "possible adult, possilby good" if inbetween the limits
  ##label them possible adult because this may include unlabeled lifeStages
    for(j in 1:nrow(sub)){
      if(isTRUE(sub$measurementValue[j] < sub$lowerLimit[1])){
        data$measurementStatus[data$index == sub$index[j]] <- "possible juvenile"
      }
      else if(isTRUE(sub$measurementValue[j] > sub$upperLimit[1])){
        data$measurementStatus[data$index == sub$index[j]] <- "outlier"
      }
      else{
        data$measurementStatus[data$index == sub$index[j]] <- "possible adult, possibly good"
      }
    }
  } 

return(data)
}
  
  
  
  
  
  
  
  #new for loop because need to include new measurementStatus entries  
  for(i in 1:length(sp)){
    #create a subset of data of just the data we want to use to test normality
    #create a dataframe of just the measurements of the select trait for a species
    sub <- subset(data, subset = data[, "scientificName"] == sp[i] &
                                 data[, "measurementType"] == trait &
                                 !(data[, "measurementStatus"] %in% status))
    
    #if they have lifeStage not null, trim the dataset more
    if(!isTRUE(is.null(stage))){
      sub <- subset(sub, subset = sub[, "lifeStage"] == stage)
    }
    
    #make numeric
    sub[, "measurementValue"] <- as.numeric(sub[, "measurementValue"]) 
    
    #remove NAs from measurementValue
    sub <- sub[!is.na("measurementValue"),]
    
    #tests for normality
    ##first, if there aren't enough unique records, maybe because of duplication, then 
   
