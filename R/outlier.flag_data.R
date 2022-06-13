## use Mahalanobis Distance test to test for outliers in one trait in each species in the dataset

outlier.flag <- function(
    #assume column names match template
  data, #a dataframe, assumed to be in FuTRES format
  trait, #measurementType of interest
  stage = NULL, #omits by default
  taxa = NULL, #by default does all the species in the dataset
  #assume trait is under "measurementType" and an FOVT term
  sample.limit = NULL #limit for number of samples for testing outliers, defaults to 10
  #assumes dataset is already filtered by lifeStage and ageValue
  #goes through every species in the dataset
) 
{
  
  #add in column to record status of the measurment
  #(e.g., "too few records", "outlier", "")
  if(!isTRUE(colnames(data) %in% "measurementStatus")){
    data[, "measurementStatus"] <- ""
  }
  
  #create index of species names to go through
  #by default goes through all species in the dataset
  if(isTRUE(is.null(taxa))){
    sp <- unique(data[,"scientificName"])
  }
  else{
    sp <- taxa
  }
  
  rownames(data) <- seq(1, nrow(data),1)
  
  for(i in 1:length(sp)){
    #create a dataframe of just the measurements of the select trait for a species
    trim <- subset(data, subset = data[, "scientificName"] == sp[i] &
                     data[, "measurementType"] == trait)
    
    #if they have lifeStage not null, trim the dataset more
    if(!isTRUE(is.null(stage))){
      trim <- subset(trim, subset = trim[, "lifeStage"] == stage)
    }
    
    #select out only measurement value
    sub <- subset(trim, select = "measurementValue")
    
    #make numeric
    sub[, "measurementValue"] <- as.numeric(sub[, "measurementValue"]) 
    
    #remove NAs
    sub  <- na.omit(sub)
    
    #set limit
    if(isTRUE(is.null(sample.limit))){
      n.limit = 10
    }
    else{
      n.limit = sample.limit
    }
    
    if(isTRUE(nrow(sub) == 0)){
      next #if it is an empty dataframe, do nothing and go to the next species
    }
    else if(isTRUE(length(unique(sub[, "measurementValue"])) <= n.limit | 
                   nrow(sub) <= n.limit)){ #TRUE if not enough observations based on sample.limit
      data[, "measurementStatus"][data[, "scientificName"] == sp[i] &
                                    data[, "measurementType"] == trait] <- "too few records"
    }
    else if(isTRUE(nrow(sub) >= n.limit)){ #if enough observations, do the outlier test
      outlier <- maha(sub, cutoff = 0.95, rnames = FALSE) #do the test
      index <- names(outlier[[2]]) #indexing values that are outliers
      if(isTRUE(length(index) != 0)){
        data[index,"measurementStatus"] <- "outlier" #labeling values that are outliers
      }
    }
    else{
      next
    }
  }
  return(data) #returns the full dataframe
  #this means that the traits and species not specified will not have values in "measurementStatus"
}                
