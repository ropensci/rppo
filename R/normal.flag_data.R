## tests if data is normal and then if data is within some standard deviation of it

normal.flag <- function(
  data,
  stage,
  age,
  sigma
  )
  {
 
sp <- unique(data$scientificName)
data$normality <- ""
method <- c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value")
status <- c("outlier", "too few records")
data$index <- rownames(data)
data$sample.size <- ""
  
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

for(i in 1:length(sp)){
  sub <- subset(df.norm, subset = data$scientificName == sp[i] &
                                  !(data$measurementStatus %in% status) &
                                  data$lifeStage == "adult" |
                                  data$ageValue >= age &
                                  !(data$measurementMethod %in% method))
 
   sub$measurmeentValue <- as.numeric(sub$measurementValue) 
   sub <- !is.na(sub)
  
  if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) < 3 |
            length(unique(sub$measurementValue[sub$measurementType == trait])) < 3)){
    data$normality[data$scientificName == sp[i] & 
                   data$measurementType == trait &
                   !(data$measurementStatus %in% status) &
                   data$lifeStage == "adult" |
                   data$ageValue >= age &
                   !(data$measurementMethod %in% method] <- "too few records"
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) > 5000)){
    x <- sample(sub$measurementValue[sub$measurementType == trait], 
                5000, replace = FALSE, prob = NULL)
    normal.total.length <- shapiro.test(x)
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i] &
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == "adult" |
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      data$normality[data$measurementType == "{body length}" & 
                     data$scientificName == sp[i] &
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == "adult" |
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method] <- "normal"
    }
  }
  else if(isTRUE(length(sub$measurementValue[sub$measurementType == trait]) <= 5000 & 
                 length(sub$measurementValue[sub$measurementType == trait]) >= 3) & 
                 length(unique(sub$measurementValue[sub$measurementType == trait])) > 3){
    normal.total.length <- shapiro.test(sub$measurementValue[sub$measurementType == trait])
    if(isTRUE(normal.total.length[[2]] < 0.05)){
      data$normality[data$measurementType == trait & 
                     data$scientificName == sp[i] &
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == "adult" |
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method] <- "non-normal"
    }
    else if(isTRUE(normal.total.length[[2]] >= 0.05)){
      data$normality[data$measurementType == "{body length}" & 
                     data$scientificName == sp[i] &
                     !(data$measurementStatus %in% status) &
                     data$lifeStage == "adult" |
                     data$ageValue >= age &
                     !(data$measurementMethod %in% method] <- "normal"
    }
  }
  else{
    next
  }
}
           
data$upper.limit.norm <- ""
data$lower.limit.norm <- ""
data$mean <- ""
data$sigma <- ""
                       
for(i in 1:length(sp){
  data$mean[data$scientificName == sp[i] &
            !(data$measurementStatus %in% status) &
            !(data$measurementMethod %in% method) &
            data$lifeStage == stage |
            data$ageValue == age &
            data$measurementType == trait)] <- mean(data$measurementValue[data$scientificName == sp[i] &
                                                                          !(data$measurementStatus %in% status) &
                                                                          !(data$measurementMethod %in% method) &
                                                                          data$lifeStage == stage |
                                                                          data$ageValue == age &
                                                                          data$measurementType == trait)]
  data$sigma[data$scientificName == sp[i] &
             !(data$measurementStatus %in% status) &
             !(data$measurementMethod %in% method) &
             data$lifeStage == stage |
             data$ageValue == age &
             data$measurementType == trait)] <- sd(data$measurementValue[data$scientificName == sp[i] &
                                                                         !(data$measurementStatus %in% status) &
                                                                         !(data$measurementMethod %in% method) &
                                                                         data$lifeStage == stage |
                                                                         data$ageValue == age &
                                                                         data$measurementType == trait)]
                                                   
  data$upper.limit.norm[data$scientificName == sp[i] &
                        !(data$measurementStatus %in% status) &
                        !(data$measurementMethod %in% method) &
                        data$lifeStage == stage |
                        data$ageValue == age &
                        data$measurementType == trait)] <- data$mean[data$scientificName == sp[i] &
                                                                     !(data$measurementStatus %in% status) &
                                                                     !(data$measurementMethod %in% method) &
                                                                     data$lifeStage == stage |
                                                                     data$ageValue == age &
                                                                     data$measurementType == trait)] + (sigma*data$sigma[data$scientificName == sp[i] &
                                                                                                                         !(data$measurementStatus %in% status) &
                                                                                                                         !(data$measurementMethod %in% method) &
                                                                                                                         data$lifeStage == stage |
                                                                                                                         data$ageValue == age &
                                                                                                                         data$measurementType == trait)]  
                                                                                                        
  data$lower.limit.norm[data$scientificName == sp[i] &
                        !(data$measurementStatus %in% status) &
                        !(data$measurementMethod %in% method) &
                        data$lifeStage == stage |
                        data$ageValue == age &
                        data$measurementType == trait)] <- data$mean[data$scientificName == sp[i] &
                                                                     !(data$measurementStatus %in% status) &
                                                                     !(data$measurementMethod %in% method) &
                                                                     data$lifeStage == stage |
                                                                     data$ageValue == age &
                                                                     data$measurementType == trait)] - (sigma*data$sigma[data$scientificName == sp[i] &
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
    if(isTRUE(sub$measurementValue[j] <= sub$lower.limit.norm[1])){
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
