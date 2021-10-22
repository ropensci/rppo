#pass to fuction my_data_frame or r2$data (from previous futres_data() function:
#' @examples
#'
#' r1 <- futres_data(genus = "Puma", limit=10)
#'
#' r2 <- futres_data(fromYear = 2009, toYear  = 2018, bbox="37,-120,38,-119", limit=10)
#'
#' my_data_frame <- r2$data

#create limits for non-normal and non-log.normal data

quantiles.flag <- function(
  data, #dataset 
  stage = "adult", #lifeStage to include
  age, #ageValue range to include
  trait, #trait of interest
  quant,
  steps = 5, #steps for sequence (e.g., 5, 2.5)
  n.limit, #minimum sample size for creating quantiles
  method = c("Extracted with Traiter ; estimated value", "Extracted with Traiter ; estimated value; inferred value"), #data we don't want to include in the test; can change it just showing the default
  status = c("outlier", "too few records") #data we don't want to include in the test
  )
  {
 
sp <- unique(data$scientificName)
  if(!isTRUE(data$sample.size)){
    data$sample.size <- ""
    }
  if(!isTRUE(data$upperLimit)){
    data$upperLimit <- ""
   }
  if(!isTRUE(data$lowerLimit)){
    data$lowerLimit <- ""
   }
  
percent <- seq(0, 100, steps*10)
index <- length(percent)
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
                   data$measurementType == trait] <- nrow(sub)
  
  data$upperLimit[data$scientificName == sp[i] &
                   data$measurementType == trait] <- quantile(sub$measurementValue, probs = seq(0,1,steps))[[q$index[q$percent == quant]]]
  
  data$lowerLimit[data$scientificName == sp[i] &
                   data$measurementType == trait] <- quantile(sub$measurementValue, probs = seq(0,1,steps))[[q$index[q$percent == quant]]]
}

data$measurementStatus[data$sample.size < n.limit] <- "too few records"
data$index <- rownames(data)

for(i in 1:length(sp)){
  sub <- subset(data, data$scientificName == sp[i] &
                      data$measurementType == trait &
                      !(data$measurementStatus %in% status))
  for(j in 1:nrow(sub)){
    if(isTRUE(sub$measurementValue[j] <= sub$lowerLimit[1])){ 
      data$measurementStatus[data$index == sub$index[j]] <- "juvenile.quant"
    }
    else if(isTRUE(sub$measurementValue[j] >= sub$upperLimit[1])){
      data$measurementStatus[data$index == sub$index[j]] <- "outlier.quant"
    }
    else{
      data$measurementStatus[data$index == sub$index[j]] <- "possible adult, possibly good"
    }
  }
} 
return(data)
}
