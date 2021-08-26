samples.flag <- function(
  data,
  stage,
  age,
  n.limit
  )
  {
 
sp <- unique(data$scientificName)
data$sample.size <- ""

for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               data$lifeStage == "adult" |
                               data$ageValue >= age))
  
  sub$measurmeentValue <- as.numeric(sub$measurementValue) 
  sub <- !is.na(sub)
   
  data$sample.size[data$scientificName == sp[i] &
                   data$measurementType == trait &                   
                   data$lifeStage == "adult" |
                   data$ageValue >= age] <- nrow(sub)
                   
data$measurementStatus[data$sample.size < n.limit] <- "too few records"
}
return(data)
}
