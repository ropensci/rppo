## use Mahalanobis Distance test to test for outliers in one trait in each species in the dataset

outlier.flag <- function(
    #assume column names match template
  data, #a dataframe, assumed to be in FuTRES format
  trait, #measurementType of interest
  stage = NULL, 
  scientificName = NULL,
  #assume trait is under "measurementType" and an FOVT term
  sample.limit = NULL #limit for number of samples for testing outliers, defaults to 10
  #assumes dataset is already filtered by lifeStage and ageValue
  #goes through every species in the dataset
) 
{

  if(!isTRUE(colnames(data) %in% "measurementStatus")){
    data[, "measurementStatus"] <- ""
  }
  else{
    next
  }
  
  sp <- unique(data[,"scientificName"])
  rownames(data) <- seq(1, nrow(data),1)
  
  for(i in 1:length(sp)){
    trim <- subset(data, subset = data[, "scientificName"] == sp[i] &
                                  data[, "measurementType"] == trait)
    if(!isTRUE(is.null(lifeStage))){
      trim <- subset(trim, subset = trim[, "lifeStage"] == stage)
    }
    
    sub <- subset(trim, select = "measurementValue")
    
    sub[, "measurmentValue"] <- as.numeric(sub[, "measurementValue"]) 
    sub <- !is.na(sub)
    
    if(isTRUE(is.null(sample.limit))){
      n.limit = 10
    }
    else{
      n.limit = sample.limit
    }

    if(isTRUE(nrow(sub) == 0)){
      next
    }
    else if(isTRUE(length(unique(sub[, "measurementValue"])) <= n.limit | 
                   nrow(sub) <= n.limit)){
      data[, "measurementStatus"][data[, "scientificName"] == sp[i] &
                                  data[, "measurementType"] == trait] <- "too few records"
    }
    else if(isTRUE(nrow(sub) >= n.limit)){
      outlier <- maha(sub, cutoff = 0.95, rnames = FALSE) #do the test
      index <- names(outlier[[2]])
      if(isTRUE(length(index) != 0)){
        data[index,"measurementStatus"] <- "outlier"
      }
    }
    else{
      next
    }
  }
  return(data)
}                
