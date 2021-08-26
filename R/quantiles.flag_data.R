quantiles.flag <- function(
  data,
  stage,
  age,
  quant,
  n.limit
  )
  {
 
sp <- unique(data$scientificName)
data$sample.size <- ""
data$upper.limit <- ""
data$lower.limit <- ""
method <- c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value")
status <- c("outlier", "too few records")
percent <- seq(0, 100, 5)
index <- c(1:21)
q <- data.frame(precent,index)
 
for(i in 1:length(sp)){
  sub <- subset(data, subset = data$scientificName == sp[i] &
                               data$measurementType == trait &
                               !(data$measurementStatus %in% status) &
                               data$lifeStage == "adult" |
                               data$ageValue >= age &
                               !(data$measurementMethod %in% method))
  
  sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
   
  data$sample.size[data$scientificName == sp[i] &
                   data$measurementType == trait &
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == "adult" |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method] <- nrow(sub)
  
  data$upper.limit[data$scientificName == sp[i] &
                   data$measurementType == trait &
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == "adult" |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method] <-quantile(sub$measurementValue, probs = seq(0,1,.05))[[q$index[q$percent = quant]]
  
  data$lower.limit[data$scientificName == sp[i] &
                   data$measurementType == trait &
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == "adult" |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method] <- quantile(sub$measurementValue, probs = seq(0,1,.05))[[q$index[q$percent = quant]]
}

data$measurementStatus[data$sample.size < n.limit] <- "too few records"
data$index <- rownames(data)

for(i in 1:length(sp)){
  sub <- subset(data, data$scientificName == sp[i] &
                      data$measurementType == trait &
                      !(data$measurementStatus %in% status)]
  for(j in 1:nrow(sub)){
    if(isTRUE(sub$measurementValue[j] <= sub$lower.limit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "possibly not adult"
    }
    else if(isTRUE(sub$measurementValue[j] >= sub$upper.limit.mass[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "possibly outlier"
    }
    else{
      data$measurementStatus[data$index == sub$index[j]] <- "possibly adult"
    }
  }
} 
return(data)
}
