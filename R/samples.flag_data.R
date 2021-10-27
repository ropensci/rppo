##label sample size for each species for each trait

samples.flag <- function(
  data, #dataset to be added
  stage, #lifeStave to include
  age, #in lieu of lifeStage, age values to include
  n.limit = 10, # minimum number of samples wanted to test for normality; default is 10
  trait #trait of interest
  )
  {
 
#create column
  if(!isTRUE(data$sample.size)){
    data$sample.size <- ""
    }
  
sp <- unique(data$scientificName)

for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               data$lifeStage == stage |
                               data$ageValue >= age)
  
  sub$measurmeentValue <- as.numeric(sub$measurementValue) 
  sub <- !is.na(sub)
   
  data$sample.size[data$scientificName == sp[i] &
                   data$measurementType == trait] <- nrow(sub)
}
  
data$measurementStatus[data$sample.size < n.limit] <- "too few records"

return(data)
}
