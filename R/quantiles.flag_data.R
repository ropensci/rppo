#create limits for non-normal and non-log.normal data

quant.flag <- function(
    data, #dataset to be added
    stage = NULL, #lifeStage to include
    sample.min = NULL, #minimum number of samples wanted to test for normality (e.g., must be greater than 3); default is 3
    #sample.min is also for the number of unique records
    #method = c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value"), #data we don't want to include in the test; can change it just showing the default
    quant = NULL, #default is 5%
    steps = NULL, #steps for sequence (e.g., 5, 2.5), default is .05
    taxa = NULL, #by default does all the species in the dataset
    status = c("outlier", "too few records"), #data we don't want to include in the test; assumes you've already done the "outlier.flag()"
    trait #trait of interest
    )
  {
 
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
  
  if(isTRUE(is.null(steps))){
    steps = .05
  }
  else{
    steps = steps
  }
  
  if(isTRUE(is.null(quant))){
    quant = 5 
  }
  else{
    quant = quant
  }
  
  data[,"index"] <- rownames(data)
  
  #create new columns if they don't currently exist
  ##if don't have one of these columns, likely don't have any
  if(!(isTRUE(colnames(data) %in% "upperLimit"))){
    data[,"upperLimit"] <- ""
    data[,"lowerLimit"] <- ""
    data[,"limitMethod"] <- ""
  }

  percent <- seq(0, 1, steps)
  index <- seq(1, length(percent), 1)
  #q <- data.frame(percent,index)
  
  lower.quant.index = 2 #this will always be 2, because 1 = 0
  upper.quant.index = length(index)-1 #this will be 1 less than the length of index, length of index = 100%
 
  for(i in 1:length(sp)){
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
    data$sample.size[data[, "scientificName"] == sp[i] &
                     data[, "measurementType"] == trait] <- as.numeric(nrow(sub))
    
    data[, "sample.size"] <- as.numeric(data[, "sample.size"])
  
    #calculate upper quantile limit
    data$upperLimit[data[, "scientificName"] == sp[i] &
                    data[, "measurementType"] == trait] <- quantile(sub$measurementValue, probs = seq(0,1,steps))[[upper.quant.index]]
  
    data[, "upperLimit"] <- as.numeric(data[, "upperLimit"])
    
    #calculate lower quantile limit
    data$lowerLimit[data[, "scientificName"] == sp[i] &
                    data[, "measurementType"] == trait] <- quantile(sub$measurementValue, probs = seq(0,1,steps))[[lower.quant.index]]
  
    data[, "lowerLimit"] <- as.numeric(data[, "lowerLimit"])
    
    #specify method
    data$limitMethod[data[, "scientificName"] == sp[i] &
                     data[, "measurementType"] == trait] <- "quantile" #label method
  }

  data$measurementStatus[data[, "sample.size"] < n.limit &
                         data[, "measurementType" == trait]] <- "too few records"

  for(i in 1:length(sp)){
    sub <- subset(data, data[, "scientificName"] == sp[i] &
                        data[, "measurementType"] == trait &
                        !(data[, "measurementStatus"] %in% status))
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
