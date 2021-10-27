## test if data is normally distributed or not, and if so, create upper and lower limits and label those outside of limits as possible outliers

#test for normality
normal.flag <- function(
  data, #dataset to be added
  stage = "adult", #lifeStage to include
  age, #in lieu of lifeStage, ageValues to incldue
  sigma, #value for how many standard deviations from the mean to calculate upper and lower limits
  n.limit = 3, #minimum number of samples wanted to test for normality (must be greater than 3); default is three
  method = c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value"), #data we don't want to include in the test; can change it just showing the default
  status = c("outlier", "too few records"), #data we don't want to include in the test
  trait #trait of interest
  )
  {
 
sp <- unique(data$scientificName)
if(!isTRUE(data$normality)){
    data$normality <- ""
  }
if(!isTRUE(data$sample.size)){
     data$sample.size <- ""
  }
  
data$index <- rownames(data)
  
for(i in 1:length(sp)){
sub <- subset(data, subset = data$scientificName == sp[i] &
                             data$measurementType == trait &
                             !(data$measurementStatus %in% status) &
                             data$lifeStage == stage |
                             data$ageValue >= age &
                             !(data$measurementMethod %in% method))
  
sub$measurmeentValue <- as.numeric(sub$measurementValue) 
sub <- sub[!is.na(sub$measurementValue),] #removing NA values
   
data$sample.size[data$scientificName == sp[i] &
                 data$measurementType == trait] <- nrow(sub)
}
  
data$measurementStatus[data$sample.size < n.limit] <- "too few records" #identify which species you don't want to include because they don't have enough samples

for(i in 1:length(sp)){
  #create a subset of data of just the data we want to use to test normality, it will go species by species for the trait selected
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == stage |
                               data$ageValue >= age &
                               !(data$measurementMethod %in% method &
                               data$normality != "log normal"))
 
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
  
  if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < n.limit |
            length(unique(sub$measurementValue[sub$measurementType == trait])) < n.limit)){ #if it is less than the sample size limit, then flag as "too few records"
    data$normality[data$scientificName == sp[i] & 
                   data$measurementType == trait] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) > 5000)){ #if it is greater than 5000, then we need to subsample
    x <- sample(sub$measurementValue[sub$measurementType == trait], 
                5000, replace = FALSE, prob = NULL)
    normal <- shapiro.test(x) #normality test
    if(isTRUE(normal[[2]] < 0.05)){ #if significantly different, then non-normal
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i]] <- "non-normal"
    }
    else if(isTRUE(normal[[2]] >= 0.05)){ #if not significantly different, then non-normal
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i]] <- "normal"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 & #if between n.limit and 5000, then test for normality
                 length(sub$measurementValue[sub$measurementType == trait]) >= n.limit) & 
                 length(unique(sub$measurementValue[sub$measurementType == trait])) > 3){
    normal.total.length <- shapiro.test(sub$measurementValue[sub$measurementType == trait]) #normality test
    if(isTRUE(normal.total.length[[2]] < 0.05)){ #if significantly different, then not normal
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i]] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){ #if not significantly different, then normal
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i]] <- "normal"
    }
  }
  else{
    next
  }
}
           
#create new columns if they don't currently exist
  if(!(isTRUE(data$upperLimit))){
    data$upperLimit <- ""
    data$lowerLimit <- ""
    data$upperLimitMethod <- ""
    data$lowerLimitMethod <- ""
  }
  if(!(isTRUE(data$meanValue))){
    data$meanValue <- ""
    data$sdValue <- ""
  }
                       
for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == stage |
                               data$ageValue >= age &
                               !(data$measurementMethod %in% method) &
                               data$normality != "non-normal") #only for normal data
  
   sub$measurementValue <- as.numeric(sub$measurementValue) 
   sub <- sub[!is.na(sub$measurementValue),]
  
  data$meanValue[data$scientificName == sp[i] &
                 data$measurementType == trait] <- mean(sub$measurementValue) #get mean value for each species and each trait
  
  data$sdValue[data$scientificName == sp[i] &
               data$measurementType == trait] <- sd(sub$measurementValue) #get standard deviation for each species and each trait
                                                   
  data$upperLimit[data$scientificName == sp[i] &
                  data$measurementType == trait] <- mean(sub$measurementValue) + sigma*sd(sub$measurementValue) #calculate upper limit as mean + sigma*sd
                                                                                                        
  data$lowerLimit[data$scientificName == sp[i] &
                  data$measurementType == trait] <- mean(sub$measurementValue) - sigma*sd(sub$measurementValue) #calculate lower limit as mean - sigma*sd

data$lowerLimitMethod[data$scientificName == sp[i] &
                      data$measurementType == trait] <- "sd, non-estimated values, no outliers" #label method
  
  data$upperLimitMethod[data$scientificName == sp[i] &
                        data$measurementType == trait] <- "sd, non-estimated values, no outliers" #label method
}
 
for(i in 1:length(sp)){
  sub <- data[data$scientificName == sp[i] & 
              data$measurementType == trait &
              !(data$measurementStatus %in% status) &
              data$lowerLimitMethod == "sd, non-estimated values, no outliers",] #only use for those that use the raw values
  
  for(j in 1:nrow(sub)){
    if(isTRUE(sub$measurementValue[j] <= sub$lowerLimit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "juvenile.sd"
    }
    else if(isTRUE(sub$measurementValue[j] >= sub$upperLimit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "outlier.sd"
    }
    else{
      data$measurementStatus[data$index == sub$index[j]] <- "possible adult, possibly good"
    }
  }
} 
                                                                                                        
  return(data)
}
